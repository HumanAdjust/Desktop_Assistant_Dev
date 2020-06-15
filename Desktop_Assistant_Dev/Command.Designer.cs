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
            this.Calcualtor = new System.Windows.Forms.Button();
            this.StopWatch = new System.Windows.Forms.Button();
            this.Check_Port = new System.Windows.Forms.Button();
            this.groupBox2 = new System.Windows.Forms.GroupBox();
            this.groupBox3 = new System.Windows.Forms.GroupBox();
            this.Cha_Nyan = new System.Windows.Forms.Button();
            this.Cha_Clippy = new System.Windows.Forms.Button();
            this.groupBox4 = new System.Windows.Forms.GroupBox();
            this.Battery_check = new System.Windows.Forms.Button();
            this.Com_Check = new System.Windows.Forms.Button();
            this.groupBox5 = new System.Windows.Forms.GroupBox();
            this.button1 = new System.Windows.Forms.Button();
            this.IPCheck = new System.Windows.Forms.Button();
            this.SystemIO.SuspendLayout();
            this.groupBox1.SuspendLayout();
            this.Con_Features.SuspendLayout();
            this.groupBox2.SuspendLayout();
            this.groupBox3.SuspendLayout();
            this.groupBox4.SuspendLayout();
            this.groupBox5.SuspendLayout();
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
            this.Con_Features.Controls.Add(this.Calcualtor);
            this.Con_Features.Controls.Add(this.StopWatch);
            this.Con_Features.Location = new System.Drawing.Point(13, 270);
            this.Con_Features.Name = "Con_Features";
            this.Con_Features.Size = new System.Drawing.Size(251, 116);
            this.Con_Features.TabIndex = 6;
            this.Con_Features.TabStop = false;
            this.Con_Features.Text = "Convenient Features";
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
            // Check_Port
            // 
            this.Check_Port.Location = new System.Drawing.Point(7, 78);
            this.Check_Port.Name = "Check_Port";
            this.Check_Port.Size = new System.Drawing.Size(141, 23);
            this.Check_Port.TabIndex = 2;
            this.Check_Port.Text = "Port Check";
            this.Check_Port.UseVisualStyleBackColor = true;
            this.Check_Port.Click += new System.EventHandler(this.Check_Port_Click);
            // 
            // groupBox2
            // 
            this.groupBox2.Controls.Add(this.groupBox3);
            this.groupBox2.Location = new System.Drawing.Point(12, 392);
            this.groupBox2.Name = "groupBox2";
            this.groupBox2.Size = new System.Drawing.Size(718, 156);
            this.groupBox2.TabIndex = 7;
            this.groupBox2.TabStop = false;
            this.groupBox2.Text = "Assistant_Settings";
            // 
            // groupBox3
            // 
            this.groupBox3.Controls.Add(this.Cha_Nyan);
            this.groupBox3.Controls.Add(this.Cha_Clippy);
            this.groupBox3.Location = new System.Drawing.Point(13, 20);
            this.groupBox3.Name = "groupBox3";
            this.groupBox3.Size = new System.Drawing.Size(168, 130);
            this.groupBox3.TabIndex = 0;
            this.groupBox3.TabStop = false;
            this.groupBox3.Text = "characters";
            // 
            // Cha_Nyan
            // 
            this.Cha_Nyan.Location = new System.Drawing.Point(87, 20);
            this.Cha_Nyan.Name = "Cha_Nyan";
            this.Cha_Nyan.Size = new System.Drawing.Size(75, 23);
            this.Cha_Nyan.TabIndex = 1;
            this.Cha_Nyan.Text = "NyanGirl";
            this.Cha_Nyan.UseVisualStyleBackColor = true;
            this.Cha_Nyan.Click += new System.EventHandler(this.Cha_Nyan_Click);
            // 
            // Cha_Clippy
            // 
            this.Cha_Clippy.Location = new System.Drawing.Point(6, 20);
            this.Cha_Clippy.Name = "Cha_Clippy";
            this.Cha_Clippy.Size = new System.Drawing.Size(75, 23);
            this.Cha_Clippy.TabIndex = 0;
            this.Cha_Clippy.Text = "Clippy";
            this.Cha_Clippy.UseVisualStyleBackColor = true;
            this.Cha_Clippy.Click += new System.EventHandler(this.Cha_Clippy_Click);
            // 
            // groupBox4
            // 
            this.groupBox4.Controls.Add(this.Battery_check);
            this.groupBox4.Controls.Add(this.Com_Check);
            this.groupBox4.Location = new System.Drawing.Point(13, 148);
            this.groupBox4.Name = "groupBox4";
            this.groupBox4.Size = new System.Drawing.Size(250, 116);
            this.groupBox4.TabIndex = 6;
            this.groupBox4.TabStop = false;
            this.groupBox4.Text = "System Configuration";
            // 
            // Battery_check
            // 
            this.Battery_check.Location = new System.Drawing.Point(7, 49);
            this.Battery_check.Name = "Battery_check";
            this.Battery_check.Size = new System.Drawing.Size(235, 23);
            this.Battery_check.TabIndex = 1;
            this.Battery_check.Text = "Battary DIagnosis";
            this.Battery_check.UseVisualStyleBackColor = true;
            this.Battery_check.Click += new System.EventHandler(this.Battery_check_Click);
            // 
            // Com_Check
            // 
            this.Com_Check.Location = new System.Drawing.Point(7, 20);
            this.Com_Check.Name = "Com_Check";
            this.Com_Check.Size = new System.Drawing.Size(235, 23);
            this.Com_Check.TabIndex = 0;
            this.Com_Check.Text = "Computer Security Diagnosis";
            this.Com_Check.UseVisualStyleBackColor = true;
            this.Com_Check.Click += new System.EventHandler(this.Com_Check_Click);
            // 
            // groupBox5
            // 
            this.groupBox5.Controls.Add(this.Check_Port);
            this.groupBox5.Controls.Add(this.button1);
            this.groupBox5.Controls.Add(this.IPCheck);
            this.groupBox5.Location = new System.Drawing.Point(269, 13);
            this.groupBox5.Name = "groupBox5";
            this.groupBox5.Size = new System.Drawing.Size(155, 116);
            this.groupBox5.TabIndex = 7;
            this.groupBox5.TabStop = false;
            this.groupBox5.Text = "Network Panel";
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(7, 49);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(141, 23);
            this.button1.TabIndex = 1;
            this.button1.Text = "Battary DIagnosis";
            this.button1.UseVisualStyleBackColor = true;
            // 
            // IPCheck
            // 
            this.IPCheck.Location = new System.Drawing.Point(7, 20);
            this.IPCheck.Name = "IPCheck";
            this.IPCheck.Size = new System.Drawing.Size(141, 23);
            this.IPCheck.TabIndex = 0;
            this.IPCheck.Text = "Check My IP Address";
            this.IPCheck.UseVisualStyleBackColor = true;
            this.IPCheck.Click += new System.EventHandler(this.IPCheck_Click);
            // 
            // Command
            // 
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(742, 560);
            this.Controls.Add(this.groupBox5);
            this.Controls.Add(this.groupBox4);
            this.Controls.Add(this.groupBox2);
            this.Controls.Add(this.Con_Features);
            this.Controls.Add(this.SystemIO);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "Command";
            this.Text = "Command";
            this.SystemIO.ResumeLayout(false);
            this.groupBox1.ResumeLayout(false);
            this.Con_Features.ResumeLayout(false);
            this.groupBox2.ResumeLayout(false);
            this.groupBox3.ResumeLayout(false);
            this.groupBox4.ResumeLayout(false);
            this.groupBox5.ResumeLayout(false);
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
        private System.Windows.Forms.Button Check_Port;
        private System.Windows.Forms.Button Calcualtor;
        private System.Windows.Forms.GroupBox groupBox2;
        private System.Windows.Forms.GroupBox groupBox3;
        private System.Windows.Forms.Button Cha_Nyan;
        private System.Windows.Forms.Button Cha_Clippy;
        private System.Windows.Forms.GroupBox groupBox4;
        private System.Windows.Forms.Button Com_Check;
        private System.Windows.Forms.Button Battery_check;
        private System.Windows.Forms.GroupBox groupBox5;
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button IPCheck;
    }
}