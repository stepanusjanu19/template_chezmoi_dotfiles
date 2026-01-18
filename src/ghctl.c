#define _POSIX_C_SOURCE 200809L

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <limits.h>
#include <linux/limits.h>


#define MAX 1024

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

void expand_home(char *out, const char *path) {
    if (path[0] == '~')
        snprintf(out, MAX, "%s%s", getenv("HOME"), path + 1);
    else
        strncpy(out, path, MAX);
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


void sync_mode() {
    char path[MAX], remote[MAX], url[MAX], branch[MAX];
    char fullpath[MAX], gitdir[MAX];
    char cwd[PATH_MAX];

    getcwd(cwd, sizeof(cwd));

    while (scanf("%1023s %1023s %1023s %1023s",
                 path, remote, url, branch) == 4) {

        expand_home(fullpath, path);
        snprintf(gitdir, MAX, "%s/.git", fullpath);

        pre_hook("sync", "repo", fullpath);

        if (!exists(gitdir)) {
            char *clone[] = {"git", "clone", url, fullpath, NULL};
            run(clone);
        }

        chdir(fullpath);
    
        char *check[] = {"git", "remote", "get-url", remote, NULL};

        pid_t pid = fork();
        int status = 0;

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

        char *checkout[] = {"git", "checkout", branch, NULL};
        run(checkout);

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

