namespace Desktop_Assistant
{
    partial class IPCheck
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
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(IPCheck));
            this.external_ip = new System.Windows.Forms.TextBox();
            this.internel_ip_text = new System.Windows.Forms.Label();
            this.external_ip_text = new System.Windows.Forms.Label();
            this.internel_ip = new System.Windows.Forms.TextBox();
            this.Check = new System.Windows.Forms.Button();
            this.SuspendLayout();
            // 
            // external_ip
            // 
            this.external_ip.Location = new System.Drawing.Point(86, 17);
            this.external_ip.Name = "external_ip";
            this.external_ip.Size = new System.Drawing.Size(184, 21);
            this.external_ip.TabIndex = 0;
            // 
            // internel_ip_text
            // 
            this.internel_ip_text.AutoSize = true;
            this.internel_ip_text.Font = new System.Drawing.Font("굴림", 10F);
            this.internel_ip_text.Location = new System.Drawing.Point(12, 55);
            this.internel_ip_text.Name = "internel_ip_text";
            this.internel_ip_text.Size = new System.Drawing.Size(68, 14);
            this.internel_ip_text.TabIndex = 1;
            this.internel_ip_text.Text = "내부 IP : ";
            // 
            // external_ip_text
            // 
            this.external_ip_text.AutoSize = true;
            this.external_ip_text.Font = new System.Drawing.Font("굴림", 10F);
            this.external_ip_text.Location = new System.Drawing.Point(12, 19);
            this.external_ip_text.Name = "external_ip_text";
            this.external_ip_text.Size = new System.Drawing.Size(68, 14);
            this.external_ip_text.TabIndex = 2;
            this.external_ip_text.Text = "외부 IP : ";
            // 
            // internel_ip
            // 
            this.internel_ip.Location = new System.Drawing.Point(86, 53);
            this.internel_ip.Name = "internel_ip";
            this.internel_ip.Size = new System.Drawing.Size(184, 21);
            this.internel_ip.TabIndex = 3;
            // 
            // Check
            // 
            this.Check.Location = new System.Drawing.Point(287, 17);
            this.Check.Name = "Check";
            this.Check.Size = new System.Drawing.Size(74, 57);
            this.Check.TabIndex = 4;
            this.Check.Text = "확인";
            this.Check.UseVisualStyleBackColor = true;
            this.Check.Click += new System.EventHandler(this.Check_Click);
            // 
            // IPCheck
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(7F, 12F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(376, 89);
            this.Controls.Add(this.Check);
            this.Controls.Add(this.internel_ip);
            this.Controls.Add(this.external_ip_text);
            this.Controls.Add(this.internel_ip_text);
            this.Controls.Add(this.external_ip);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.Icon = ((System.Drawing.Icon)(resources.GetObject("$this.Icon")));
            this.Name = "IPCheck";
            this.Text = "IPCheck";
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.TextBox external_ip;
        private System.Windows.Forms.Label internel_ip_text;
        private System.Windows.Forms.Label external_ip_text;
        private System.Windows.Forms.TextBox internel_ip;
        private System.Windows.Forms.Button Check;
    }
}