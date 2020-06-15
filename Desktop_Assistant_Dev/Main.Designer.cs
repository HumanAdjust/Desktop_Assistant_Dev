namespace Desktop_Assistant
{
    partial class Main
    {
        /// <summary>
        /// 필수 디자이너 변수입니다.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 사용 중인 모든 리소스를 정리합니다.
        /// </summary>
        /// <param name="disposing">관리되는 리소스를 삭제해야 하면 true이고, 그렇지 않으면 false입니다.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form 디자이너에서 생성한 코드

        /// <summary>
        /// 디자이너 지원에 필요한 메서드입니다. 
        /// 이 메서드의 내용을 코드 편집기로 수정하지 마세요.
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Main));
            this.menu = new System.Windows.Forms.ContextMenuStrip(this.components);
            this.AlwaysOnTop = new System.Windows.Forms.ToolStripMenuItem();
            this.AOS_ON = new System.Windows.Forms.ToolStripMenuItem();
            this.AOS_OFF = new System.Windows.Forms.ToolStripMenuItem();
            this.Exit = new System.Windows.Forms.ToolStripMenuItem();
            this.Character = new System.Windows.Forms.ToolStripMenuItem();
            this.Clippy = new System.Windows.Forms.ToolStripMenuItem();
            this.SCP173 = new System.Windows.Forms.ToolStripMenuItem();
            this.SCP049 = new System.Windows.Forms.ToolStripMenuItem();
            this.CG = new System.Windows.Forms.ToolStripMenuItem();
            this.menu.SuspendLayout();
            this.SuspendLayout();
            // 
            // menu
            // 
            this.menu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.Character,
            this.AlwaysOnTop,
            this.Exit});
            this.menu.Name = "menu";
            this.menu.Size = new System.Drawing.Size(181, 92);
            // 
            // AlwaysOnTop
            // 
            this.AlwaysOnTop.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.AOS_ON,
            this.AOS_OFF});
            this.AlwaysOnTop.Name = "AlwaysOnTop";
            this.AlwaysOnTop.Size = new System.Drawing.Size(180, 22);
            this.AlwaysOnTop.Text = "Always On Top";
            // 
            // AOS_ON
            // 
            this.AOS_ON.Name = "AOS_ON";
            this.AOS_ON.Size = new System.Drawing.Size(95, 22);
            this.AOS_ON.Text = "ON";
            this.AOS_ON.Click += new System.EventHandler(this.AOS_ON_Click);
            // 
            // AOS_OFF
            // 
            this.AOS_OFF.Name = "AOS_OFF";
            this.AOS_OFF.Size = new System.Drawing.Size(95, 22);
            this.AOS_OFF.Text = "OFF";
            this.AOS_OFF.Click += new System.EventHandler(this.AOS_OFF_Click);
            // 
            // Exit
            // 
            this.Exit.Name = "Exit";
            this.Exit.Size = new System.Drawing.Size(180, 22);
            this.Exit.Text = "Exit";
            this.Exit.Click += new System.EventHandler(this.Exit_Click);
            // 
            // Character
            // 
            this.Character.DropDownItems.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.Clippy,
            this.SCP173,
            this.SCP049,
            this.CG});
            this.Character.Name = "Character";
            this.Character.Size = new System.Drawing.Size(180, 22);
            this.Character.Text = "Character";
            // 
            // Clippy
            // 
            this.Clippy.Name = "Clippy";
            this.Clippy.Size = new System.Drawing.Size(180, 22);
            this.Clippy.Text = "Clippy";
            this.Clippy.Click += new System.EventHandler(this.Clippy_Click);
            // 
            // SCP173
            // 
            this.SCP173.Name = "SCP173";
            this.SCP173.Size = new System.Drawing.Size(180, 22);
            this.SCP173.Text = "SCP-173";
            this.SCP173.Click += new System.EventHandler(this.SCP173_Click);
            // 
            // SCP049
            // 
            this.SCP049.Name = "SCP049";
            this.SCP049.Size = new System.Drawing.Size(180, 22);
            this.SCP049.Text = "SCP-049";
            this.SCP049.Click += new System.EventHandler(this.SCP049_Click);
            // 
            // CG
            // 
            this.CG.Name = "CG";
            this.CG.Size = new System.Drawing.Size(180, 22);
            this.CG.Text = "Cat-Girl";
            this.CG.Click += new System.EventHandler(this.CG_Click);
            // 
            // Main
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.BackColor = System.Drawing.SystemColors.Control;
            this.BackgroundImageLayout = System.Windows.Forms.ImageLayout.Stretch;
            this.ClientSize = new System.Drawing.Size(410, 920);
            this.ContextMenuStrip = this.menu;
            this.DoubleBuffered = true;
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Main";
            this.Text = "Main";
            this.TransparencyKey = System.Drawing.SystemColors.Control;
            this.Load += new System.EventHandler(this.Main_Load);
            this.DoubleClick += new System.EventHandler(this.Main_DoubleClick);
            this.menu.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.ContextMenuStrip menu;
        private System.Windows.Forms.ToolStripMenuItem AlwaysOnTop;
        private System.Windows.Forms.ToolStripMenuItem Exit;
        private System.Windows.Forms.ToolStripMenuItem AOS_ON;
        private System.Windows.Forms.ToolStripMenuItem AOS_OFF;
        private System.Windows.Forms.ToolStripMenuItem Character;
        private System.Windows.Forms.ToolStripMenuItem Clippy;
        private System.Windows.Forms.ToolStripMenuItem SCP173;
        private System.Windows.Forms.ToolStripMenuItem SCP049;
        private System.Windows.Forms.ToolStripMenuItem CG;
    }
}

