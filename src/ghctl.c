#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <limits.h>
#include <linux/limits.h>
#include <dirent.h>

#define MAX 1024

char *realpath(const char *restrict path,
               char *restrict resolved_path);

int exists(const char *path) {
    struct stat st;
    return stat(path, &st) == 0;
}

void set_env(const char *k, const char *v) {
    if (v) setenv(k, v, 1);
}

int run(char *const argv[]) {
    pid_t pid = fork();
    int status = 0;

    if (pid == 0) {
        execvp(argv[0], argv);
        perror("execvp");
        exit(127);
    }

    waitpid(pid, &status, 0);

    if (WIFEXITED(status))
        return WEXITSTATUS(status);
    return 1;
}


int find_project_root(char *out) {
    char path[PATH_MAX];
    getcwd(path, sizeof(path));

    while (1) {
        char git[PATH_MAX];
        snprintf(git, sizeof(git), "%s/.git", path);
        if (exists(git)) {
            strcpy(out, path);
            return 1;
        }

        if (strcmp(path, "/") == 0) break;
        char *s = strrchr(path, '/');
        if (!s) break;
        *s = 0;
    }
    return 0;
}


int capture(char *const argv[], char *out, size_t sz) {
    int fd[2];
    pipe(fd);

    pid_t pid = fork();
    if (pid == 0) {
        dup2(fd[1], STDOUT_FILENO);
        close(fd[0]);
        close(fd[1]);
        execvp(argv[0], argv);
        exit(127);
    }

    close(fd[1]);
    ssize_t n = read(fd[0], out, sz - 1);
    close(fd[0]);
    waitpid(pid, NULL, 0);

    if (n <= 0) return 1;
    out[n] = 0;
    out[strcspn(out, "\n")] = 0;
    return 0;
}



int detect_default_branch(char *branch, size_t sz) {
    char buf[4096] = {0};

    if (capture((char*[]){"git","remote","show","origin",NULL},
                buf, sizeof(buf)) != 0)
        return 0;

    char *p = strstr(buf, "HEAD branch:");
    if (!p) return 0;

    p += strlen("HEAD branch:");
    while (*p == ' ') p++;

    char *e = strchr(p, '\n');
    if (e) *e = 0;

    strncpy(branch, p, sz);
    return 1;
}


int detect_default_branch_remote_fallback(char *branch, size_t sz) {
    char buf[4096] = {0};

    if (capture((char*[]){"git","remote","show","origin",NULL},
                buf, sizeof(buf)) != 0)
        return 0;

    char *p = strstr(buf, "HEAD branch:");
    if (!p) return 0;

    p += strlen("HEAD branch:");
    while (*p == ' ') p++;

    char *e = strchr(p, '\n');
    if (e) *e = 0;

    strncpy(branch, p, sz);
    return 1;
}


int is_dirty() {
    return run((char*[]){"git","diff","--quiet",NULL}) != 0 ||
           run((char*[]){"git","diff","--cached","--quiet",NULL}) != 0;
}

bool directory_has_git(const char *path) {
    char buf[PATH_MAX];
    snprintf(buf, sizeof(buf), "%s/.git", path);
    return access(buf, F_OK) == 0;
}


void expand_home(char *out, const char *path) {
    if (path[0] == '~') {
        snprintf(out, PATH_MAX, "%s%s", getenv("HOME"), path + 1);
    }
    else if (path[0] == '/') {
        strncpy(out, path, PATH_MAX - 1);
    }
    else {
        char cwd[PATH_MAX];
        getcwd(cwd, sizeof(cwd));
        snprintf(out, PATH_MAX, "%s/%s", cwd, path);
    }
}


void pre_hook(const char *mode, const char *cmd, const char *path) {
    set_env("GHCTL_MODE", mode);
    set_env("GHCTL_CMD", cmd);
    set_env("GHCTL_PATH", path);
    system("lua ~/.local/share/chezmoi/scripts/prehook.lua");
}

void post_hook(int status) {
    char buf[16];
    snprintf(buf, sizeof(buf), "%d", status);
    set_env("GHCTL_STATUS", buf);
    system("lua ~/.local/share/chezmoi/scripts/posthook.lua");
}


void prompt(const char *msg, char *out, size_t sz) {
    fprintf(stderr, "%s: ", msg);
    fflush(stderr);
    fgets(out, sz, stdin);
    out[strcspn(out, "\n")] = 0;
}


void detect_branch(char *branch, size_t sz) {
    if (capture((char*[]){"git","symbolic-ref","--short","HEAD",NULL},
                branch, sz) != 0) {
        strncpy(branch, "master", sz);
    }
}

void ensure_repos_and_redirect() {
    if (!isatty(STDIN_FILENO))
        return;
    
    char root[PATH_MAX];
    getcwd(root, sizeof(root));

    char repos[PATH_MAX];
    getcwd(repos, sizeof(repos));
    strcat(repos, "/.repos");

    if (exists(repos)) {
        freopen(repos, "r", stdin);
        return;
    }

    char url[MAX] = {0};
    char branch[MAX] = "";
    char reponame[MAX] = "";

    if (exists(".git")) {
        if (capture((char*[]){"git","remote","get-url","origin",NULL},
                    url, sizeof(url)) != 0) {
            prompt("enter remote url", url, sizeof(url));
            run((char*[]){"git","remote","add","origin",url,NULL});
        }
        detect_branch(branch, sizeof(branch));
    }
    else {
        prompt("enter remote url", url, sizeof(url));
        
        char *p = strrchr(url, '/');
        if (p) {
            strncpy(reponame, p + 1, sizeof(reponame) - 1);
            char *dot = strstr(reponame, ".git");
            if (dot) *dot = 0;
        }
        if (!reponame[0]) {
            strncpy(reponame, "repo", sizeof(reponame) - 1);
        }
    }

    FILE *f = fopen(repos, "w");
    if (reponame[0]) {
        char repopath[PATH_MAX];
        snprintf(repopath, sizeof(repopath), "%s/%s", root, reponame);
        if (branch[0]) {
            fprintf(f, "%s origin %s %s\n", repopath, url, branch);
        } else {
            fprintf(f, "%s origin %s\n", repopath, url);
        }
    } else {
        if (branch[0]) {
            fprintf(f, "%s origin %s %s\n", root, url, branch);
        } else {
            fprintf(f, "%s origin %s\n", root, url);
        }
    }
    fclose(f);

    freopen(repos, "r", stdin);
}


void sync_mode() {
    
    ensure_repos_and_redirect();

    char path[MAX], remote[MAX], url[MAX], branch[MAX];
    char fullpath[PATH_MAX], gitdir[PATH_MAX];
    char cwd[PATH_MAX];
    char repos_path[PATH_MAX];
    int status = 0;

    getcwd(cwd, sizeof(cwd));
    snprintf(repos_path, sizeof(repos_path), "%s/.repos", cwd);

    int n;
    while ((n = scanf("%1023s %1023s %1023s %1023s",
                   path, remote, url, branch)) >= 3) {
        status = 0;
        if (n < 4) branch[0] = 0;

        expand_home(fullpath, path);
        
        char realcwd[PATH_MAX];
        char realfull[PATH_MAX];
        if (realpath(cwd, realcwd) && realpath(fullpath, realfull)) {
            if (strcmp(realcwd, realfull) == 0 &&!directory_has_git(fullpath)) {
                fprintf(stderr,"ghctl: cannot clone into current directory: %s\n", fullpath);
                post_hook(1);
                continue;
            }
        }
        
        snprintf(gitdir, MAX, "%s/.git", fullpath);

        pre_hook("sync", "repo", fullpath);
        
        if (!directory_has_git(fullpath)) {
            fprintf(stderr,
                    "ghctl: skip (no .git): %s\n", fullpath);
            post_hook(0);
            continue;
        }
        
        int did_clone = 0;
        
        if (!exists(gitdir)) {
            if (exists(fullpath)) {
                if (access(fullpath, R_OK | W_OK) != 0) {
                    fprintf(stderr,
                        "ghctl: cannot access directory: %s\n", fullpath);
                    post_hook(1);
                    chdir(cwd);
                    continue;
                }
                
                DIR *d = opendir(fullpath);
                struct dirent *e;
                int count = 0;

                while (d && (e = readdir(d))) {
                    if (strcmp(e->d_name, ".") && strcmp(e->d_name, "..")) {
                        count++;
                        break;
                    }
                }

                if (d) closedir(d);

                if (count) {
                    fprintf(stderr,
                        "ghctl: directory not empty and not a git repo: %s\n", fullpath);
                    post_hook(1);
                    chdir(cwd);
                    continue;
                }
            }
            
            if (run((char*[]){"git","clone",url,fullpath,NULL}) != 0){
              post_hook(1);
              chdir(cwd);
              continue;
            }
            did_clone = 1;

            if (!branch[0]) {
                char saved_cwd[PATH_MAX];
                getcwd(saved_cwd, sizeof(saved_cwd));
                chdir(fullpath);
                detect_branch(branch, sizeof(branch));
                chdir(saved_cwd);
            }
            
            if (branch[0]) {
                FILE *f = fopen(repos_path, "w");
                if (f) {
                    fprintf(f, "%s %s %s %s\n", fullpath, remote, url, branch);
                    fclose(f);
                }
            }
            
            post_hook(status);
            continue;
        }
        
        chdir(fullpath);
        
        char *check[] = {"git", "remote", "get-url", remote, NULL};
        pid_t pid = fork();

        if (pid == 0) {
            execvp(check[0], check);
            exit(127);
        }

        waitpid(pid, &status, 0);

        if (WIFEXITED(status))
            status = WEXITSTATUS(status);
        else
            status = 1;


        if (status != 0) {
            char *add[] = {"git", "remote", "add", remote, url, NULL};
            run(add);
        }

        char *seturl[] = {"git", "remote", "set-url", remote, url, NULL};
        run(seturl);

        char *fetch[] = {"git", "fetch", "--all", "--prune", NULL};
        run(fetch);

        if (!branch[0]) {
            if (!detect_default_branch(branch, sizeof(branch))) {
                strcpy(branch, "master");
            }
        }
        
        if (is_dirty()) {
            fprintf(stderr,
                    "ghctl: working tree is dirty, aborting checkout\n");
            post_hook(1);
            chdir(cwd);
            continue;
        }
        
        
        if (branch[0]) {
            if (run((char*[]){"git","rev-parse","--verify",branch,NULL}) != 0) {
                char upstream[PATH_MAX]; 
                snprintf(upstream, sizeof(upstream), "origin/%s", branch);
                run((char*[]){"git","checkout","-b",branch,"--track",upstream,NULL});
            } else {
                run((char*[]){"git","checkout",branch,NULL});
            }
        }

        post_hook(status);
        chdir(cwd);
    }
}


void exec_mode(int argc, char **argv) {
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));

    char **git_argv = malloc(sizeof(char*) * (argc + 2));
    git_argv[0] = "git";
    for (int i = 0; i < argc; i++)
        git_argv[i + 1] = argv[i];
    git_argv[argc + 1] = NULL;

    pre_hook("exec", argv[0], cwd);
    int status = run(git_argv);
    post_hook(status);

    free(git_argv);
}


int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr,
            "usage:\n"
            "  ghctl sync              # stdin repo control\n"
            "  ghctl exec <git args>   # git passthrough\n"
        );
        return 1;
    }

    if (strcmp(argv[1], "sync") == 0) {
        sync_mode();
    }
    else if (strcmp(argv[1], "exec") == 0) {
        if (argc < 3) {
            fprintf(stderr, "ghctl exec requires git arguments\n");
            return 1;
        }
        exec_mode(argc - 2, &argv[2]);
    }
    else {
        fprintf(stderr, "unknown command: %s\n", argv[1]);
        return 1;
    }
    return 0;
}
