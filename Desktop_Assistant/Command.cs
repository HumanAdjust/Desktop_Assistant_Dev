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
        public Command()
        {
            InitializeComponent();
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
            Calculator calc = new Calculator();
            calc.Show();
        }
    }
}
