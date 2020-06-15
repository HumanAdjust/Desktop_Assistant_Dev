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
    public partial class Main : Form
    {
        bool On;
        Point Pos;

        public Main()
        {
            InitializeComponent();

            MouseDown += (o, e) => { if (e.Button == MouseButtons.Left) { On = true; Pos = e.Location; } };
            MouseMove += (o, e) => { if (On) Location = new Point(Location.X + (e.X - Pos.X), Location.Y + (e.Y - Pos.Y)); };
            MouseUp += (o, e) => { if (e.Button == MouseButtons.Left) { On = false; Pos = e.Location; } };
        }

        private void Main_Load(object sender, EventArgs e)
        {
            MessageBox.Show("Welcome Back!", "Desktop_Assistant", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        public void ChangeBGImage(Image bgImage)
        {
            this.BackgroundImage = bgImage;
        }

        private void Main_DoubleClick(object sender, EventArgs e)
        {
            Command command = new Command(this); 
            command.Show();
        }
    }
}
