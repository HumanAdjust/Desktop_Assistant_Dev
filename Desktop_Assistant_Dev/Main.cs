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
            Image Clippy = Image.FromFile(@"..\..\Idle\Clippy.png");
            this.ChangeBGImage(Clippy);
            this.Size = new Size(420, 585);
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

        private void Exit_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show("정말 종료하시겠습니까?", "Question", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
            {
                Application.Exit();
            }
        }

        private void AOS_ON_Click(object sender, EventArgs e)
        {
            this.TopMost = true;
        }

        private void AOS_OFF_Click(object sender, EventArgs e)
        {
            this.TopMost = false;
        }

        private void Clippy_Click(object sender, EventArgs e)
        {
            Image Clippy = Image.FromFile(@"..\..\Idle\Clippy.png");
            this.ChangeBGImage(Clippy);
            this.Size = new Size(420, 585);
        }

        private void SCP173_Click(object sender, EventArgs e)
        {
            Image SCP173 = Image.FromFile(@"..\..\Idle\SCP173.png");
            this.ChangeBGImage(SCP173);
            this.Size = new Size(450, 920);
        }

        private void SCP049_Click(object sender, EventArgs e)
        {
            Image SCP049 = Image.FromFile(@"..\..\Idle\SCP049.png");
            this.ChangeBGImage(SCP049);
            this.Size = new Size(410, 920);
        }

        private void CG_Click(object sender, EventArgs e)
        {
            Image Nyan = Image.FromFile(@"..\..\Idle\Nyan.png");
            this.ChangeBGImage(Nyan);
            this.Size = new Size(420, 585);
        }
    }
}
