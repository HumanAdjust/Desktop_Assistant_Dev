using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Desktop_Assistant
{
    public partial class Timer : Form
    {
        public Timer()
        {
            InitializeComponent();
        }
        int countdownNum;

        private void Button1_Click(object sender, EventArgs e)
        {
            if (IntCheck())
            {
                this.timer1.Enabled = true;
            }
        }

        private bool IntCheck()
        {
            if(Int32.TryParse(textBox1.Text, out countdownNum))
            {
                return true;
            }
            return false;
        }

        private void Timer1_Tick(object sender, EventArgs e)
        {
            if(countdownNum >= 0)
            {
                label1.Text = countdownNum.ToString();
                countdownNum--;
            }
            else
            {
                timer1.Enabled = false; // 타이머 종료
                MessageBox.Show("타이머 종료됨.", "알림", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
        }
    }
}
