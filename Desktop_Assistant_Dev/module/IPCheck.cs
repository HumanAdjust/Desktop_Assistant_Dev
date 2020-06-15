using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Desktop_Assistant
{
    public partial class IPCheck : Form
    {
        public IPCheck()
        {
            InitializeComponent();
        }

        private void Check_Click(object sender, EventArgs e)
        {
            IPHostEntry ipEntry = Dns.GetHostEntry(Dns.GetHostName());
            IPAddress[] addr = ipEntry.AddressList;

            try
            {
                String WanIP = new WebClient().DownloadString("http://ipinfo.io/ip");
                external_ip.Text = WanIP;
            }
            catch (Exception ex)
            {
                MessageBox.Show("Error", "Cannot Get External IP. Please Check Your Internet Connection.", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }

            for (int i = 0; i < addr.Length; i++)
            {
                internel_ip.Text = addr[i].ToString();
            }
        }
    }
}
