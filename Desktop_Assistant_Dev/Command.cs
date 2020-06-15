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

        private void Prg_Info_Click(object sender, EventArgs e)
        {
            MessageBox.Show("This Program will helps you experencing new comoputer.\n\n2019-2020 Made by Cloudy_Cat", "Program Information", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void Chrome_Click(object sender, EventArgs e)
        {
            Process.Start(@"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe");
        }
    }
}