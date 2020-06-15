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
            Process.Start(@"calc");
        }

        private void Cha_Clippy_Click(object sender, EventArgs e)
        {
            Main main = new Main();
            Image Clippy = Image.FromFile(@"..\..\Idle\Clippy.png");
            main.BackgroundImage = Clippy;
            main.BackgroundImageLayout = ImageLayout.Stretch; //불러온 이미지를 어떻게 세팅할 것지에 관한 것..
        }

        private void Cha_Nyan_Click(object sender, EventArgs e)
        {
            Main main = new Main();
            Image Nyan = Image.FromFile(@"..\..\Idle\Nyan.png");
            main.BackgroundImage = Nyan;
            main.BackgroundImageLayout = ImageLayout.Stretch; //불러온 이미지를 어떻게 세팅할 것지에 관한 것..
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
    }
}
