namespace Desktop_Assistant
{
    partial class Command
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(Command));
            this.SystemIO = new System.Windows.Forms.GroupBox();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.MaxSleepOff = new System.Windows.Forms.Button();
            this.MaxSleepOn = new System.Windows.Forms.Button();
            this.Logoff = new System.Windows.Forms.Button();
            this.Restart = new System.Windows.Forms.Button();
            this.Shutdown = new System.Windows.Forms.Button();
            this.Con_Features = new System.Windows.Forms.GroupBox();
            this.StopWatch = new System.Windows.Forms.Button();
            this.Calcualtor = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.SystemIO.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.Con_Features.SuspendLayout();
            this.SuspendLayout();
            // 
            // SystemIO
            // 
            this.SystemIO.Controls.Add(this.groupBox1);
            this.SystemIO.Controls.Add(this.Logoff);
            this.SystemIO.Controls.Add(this.Restart);
            this.SystemIO.Controls.Add(this.Shutdown);
            this.SystemIO.Location = new System.Drawing.Point(13, 13);
            this.SystemIO.Name = "SystemIO";
            this.SystemIO.Size = new System.Drawing.Size(250, 116);
            this.SystemIO.TabIndex = 0;
            this.SystemIO.TabStop = false;
            this.SystemIO.Text = "System I/O";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.MaxSleepOff);
            this.groupBox1.Controls.Add(this.MaxSleepOn);
            this.groupBox1.Location = new System.Drawing.Point(6, 64);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(238, 46);
            this.groupBox1.TabIndex = 5;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "MaxSleepMode";
            // 
            // MaxSleepOff
            // 
            this.MaxSleepOff.Location = new System.Drawing.Point(126, 17);
            this.MaxSleepOff.Name = "MaxSleepOff";
            this.MaxSleepOff.Size = new System.Drawing.Size(110, 23);
            this.MaxSleepOff.TabIndex = 4;
            this.MaxSleepOff.Text = "MaxSleep Off";
            this.MaxSleepOff.UseVisualStyleBackColor = true;
            this.MaxSleepOff.Click += new System.EventHandler(this.MaxSleepOff_Click);
            // 
            // MaxSleepOn
            // 
            this.MaxSleepOn.Location = new System.Drawing.Point(6, 17);
            this.MaxSleepOn.Name = "MaxSleepOn";
            this.MaxSleepOn.Size = new System.Drawing.Size(114, 23);
            this.MaxSleepOn.TabIndex = 3;
            this.MaxSleepOn.Text = "MaxSleep On";
            this.MaxSleepOn.UseVisualStyleBackColor = true;
            this.MaxSleepOn.Click += new System.EventHandler(this.MaxSleepOn_Click);
            // 
            // Logoff
            // 
            this.Logoff.Location = new System.Drawing.Point(169, 21);
            this.Logoff.Name = "Logoff";
            this.Logoff.Size = new System.Drawing.Size(75, 23);
            this.Logoff.TabIndex = 2;
            this.Logoff.Text = "Logoff";
            this.Logoff.UseVisualStyleBackColor = true;
            this.Logoff.Click += new System.EventHandler(this.Logoff_Click);
            // 
            // Restart
            // 
            this.Restart.Location = new System.Drawing.Point(88, 21);
            this.Restart.Name = "Restart";
            this.Restart.Size = new System.Drawing.Size(75, 23);
            this.Restart.TabIndex = 1;
            this.Restart.Text = "Restart";
            this.Restart.UseVisualStyleBackColor = true;
            this.Restart.Click += new System.EventHandler(this.Restart_Click);
            // 
            // Shutdown
            // 
            this.Shutdown.Location = new System.Drawing.Point(7, 21);
            this.Shutdown.Name = "Shutdown";
            this.Shutdown.Size = new System.Drawing.Size(75, 23);
            this.Shutdown.TabIndex = 0;
            this.Shutdown.Text = "Shutdown";
            this.Shutdown.UseVisualStyleBackColor = true;
            this.Shutdown.Click += new System.EventHandler(this.Shutdown_Click);
            // 
            // Con_Features
            // 
            this.Con_Features.Controls.Add(this.button2);
            this.Con_Features.Controls.Add(this.Calcualtor);
            this.Con_Features.Controls.Add(this.StopWatch);
            this.Con_Features.Location = new System.Drawing.Point(291, 13);
            this.Con_Features.Name = "Con_Features";
            this.Con_Features.Size = new System.Drawing.Size(251, 116);
            this.Con_Features.TabIndex = 6;
            this.Con_Features.TabStop = false;
            this.Con_Features.Text = "Convenient Features";
            // 
            // StopWatch
            // 
            this.StopWatch.Location = new System.Drawing.Point(7, 21);
            this.StopWatch.Name = "StopWatch";
            this.StopWatch.Size = new System.Drawing.Size(75, 23);
            this.StopWatch.TabIndex = 0;
            this.StopWatch.Text = "Timer";
            this.StopWatch.UseVisualStyleBackColor = true;
            this.StopWatch.Click += new System.EventHandler(this.StopWatch_Click);
            // 
            // Calcualtor
            // 
            this.Calcualtor.Location = new System.Drawing.Point(88, 21);
            this.Calcualtor.Name = "Calcualtor";
            this.Calcualtor.Size = new System.Drawing.Size(75, 23);
            this.Calcualtor.TabIndex = 1;
            this.Calcualtor.Text = "Calculator";
            this.Calcualtor.UseVisualStyleBackColor = true;
            this.Calcualtor.Click += new System.EventHandler(this.Calcualtor_Click);
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(169, 21);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(75, 23);
            this.button2.TabIndex = 2;
            this.button2.UseVisualStyleBackColor = true;
            // 
            // Command
            // 
            this.ClientSize = new System.Drawing.Size(778, 560);
            this.Controls.Add(this.Con_Features);
            this.Controls.Add(this.SystemIO);
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Command";
            this.Text = "Command";
            this.SystemIO.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.Con_Features.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion
        private System.Windows.Forms.Button Logoff;
        private System.Windows.Forms.Button Restart;
        private System.Windows.Forms.Button Shutdown;
        private System.Windows.Forms.Button MaxSleepOn;
        private System.Windows.Forms.Button MaxSleepOff;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.GroupBox SystemIO;
        private System.Windows.Forms.GroupBox Con_Features;
        private System.Windows.Forms.Button StopWatch;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button Calcualtor;
    }
}