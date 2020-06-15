using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Diagnostics;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Desktop_Assistant
{
    public partial class Command : Form
    {
        private Main _form1 = null;

        public Command(Main main)
        {
            InitializeComponent();
            _form1 = main;
        }

        private void Shutdown_Click(object sender, EventArgs e)
        {
            Process.Start("shutdown.exe", "-s -t 0");
        }

        private void Restart_Click(object sender, EventArgs e)
        {
            Process.Start("shutdown.exe", "-r -t 0");
        }

        private void Logoff_Click(object sender, EventArgs e)
        {
            Process.Start("shutdown.exe", "-l -t 0");
        }

        private void MaxSleepOn_Click(object sender, EventArgs e)
        {
            Process.Start("powercfg.exe", "-h on");
        }

        private void MaxSleepOff_Click(object sender, EventArgs e)
        {
            Process.Start("powercfg.exe", "-h off");
        }

        private void StopWatch_Click(object sender, EventArgs e)
        {
            Timer stopwatch = new Timer();
            stopwatch.Show();
        }

        private void Calcualtor_Click(object sender, EventArgs e)
        {
            Process.Start(@"calc");
        }

        private void Cha_Clippy_Click(object sender, EventArgs e)
        {
            Image Clippy = Image.FromFile(@"..\..\Idle\Clippy.png");
            _form1.ChangeBGImage(Clippy);
            _form1.Size = new Size(420, 585);
        }

        private void Cha_Nyan_Click(object sender, EventArgs e)
        {
            Image Nyan = Image.FromFile(@"..\..\Idle\Nyan.png");
            _form1.ChangeBGImage(Nyan);
            _form1.Size = new Size(420, 585);
        }

        private void Com_Check_Click(object sender, EventArgs e)
        {
            Process.Start(@"..\..\Programs\infosec\Windows.bat");
        }

        private void Battery_check_Click(object sender, EventArgs e)
        {
            Process.Start(@"..\..\Programs\Battery.bat");
        }

        private void IPCheck_Click(object sender, EventArgs e)
        {
            IPCheck ipc = new IPCheck();
            ipc.Show();
        }

        private void Check_Port_Click(object sender, EventArgs e)
        {
            Serial se = new Serial();
            se.Show();
        }

        private void Exit_Click(object sender, EventArgs e)
        {
            if(MessageBox.Show("정말 종료하시겠습니까?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                Application.Exit();
            }
        }

        private void SCP173_Click(object sender, EventArgs e)
        {
            Image SCP173 = Image.FromFile(@"..\..\Idle\SCP173.png");
            _form1.ChangeBGImage(SCP173);
            _form1.Size = new Size(400, 760);
        }

        private void AOT_ON_Click(object sender, EventArgs e)
        {
            _form1.TopMost = true;
        }

        private void AOT_OFF_Click(object sender, EventArgs e)
        {
            _form1.TopMost = false;
        }
    }
}