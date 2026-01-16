-- CI/CD Sync Configuration
return {
    chezmoi_root = "/home/thinkpadx395_kei19/.local/share/chezmoi",
    
    sync = {
        auto_pull = true,
        auto_apply = true,
        auto_commit = false,
    },
    
    git = {
        pull_rebase = true,
        commit_msg = "Sync from " .. (os.getenv("HOSTNAME") or "local"),
    },
    
    run = function(self)
        print("🔄 Starting sync...")
        
        os.execute("cd " .. self.chezmoi_root)
        
        if self.sync.auto_pull then
            print("📥 Pulling...")
            os.execute("cd " .. self.chezmoi_root .. " && git pull --rebase")
        end
        
        if self.sync.auto_apply then
            print("✨ Applying...")
            os.execute("chezmoi apply")
        end
        
        print("✅ Sync complete!")
    end
}