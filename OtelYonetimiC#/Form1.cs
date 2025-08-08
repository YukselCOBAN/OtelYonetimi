using Npgsql;
using System;
using System.Data;
using System.Windows.Forms;

namespace VTYSProjesi
{
    public partial class Form1 : Form
    {
        NpgsqlConnection baglanti;
        NpgsqlCommand komut;
        NpgsqlDataAdapter da;

        public Form1()
        {
            InitializeComponent();
        }

        void KisiGetir()
        {
            try
            {
                baglanti = new NpgsqlConnection("Host=localhost;Port=5432;Username=postgres;Password=examplePassword;Database=PROJE;");
                baglanti.Open(); // Bağlantıyı aç

                da = new NpgsqlDataAdapter("SELECT * FROM kisi.\"Kisi\"", baglanti); // SQL sorgusu
                DataTable table = new DataTable();
                da.Fill(table); // Veriyi doldur

                dataGridView1.DataSource = table; // DataGridView'e veri aktar
                baglanti.Close(); // Bağlantıyı kapat
            }
            catch (Exception ex)
            {
                MessageBox.Show("Hata: " + ex.Message); // Hata mesajı göster
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            KisiGetir();
        }

        private void dataGridView1_CellEnter(object sender, DataGridViewCellEventArgs e)
        {

            textBox4.Text = dataGridView1.CurrentRow.Cells[0].Value.ToString();
            textBox1.Text = dataGridView1.CurrentRow.Cells[1].Value.ToString();
            textBox2.Text = dataGridView1.CurrentRow.Cells[2].Value.ToString();
            textBox3.Text = dataGridView1.CurrentRow.Cells[3].Value.ToString();

        }

        private void button1_Click(object sender, EventArgs e)
        {

            string sorgu = "INSERT INTO kisi.\"Kisi\" (adi, \"soyadi\", \"kisiTipi\") VALUES (@adi, @soyadi, @kisiTipi)";

            komut = new NpgsqlCommand(sorgu, baglanti);


            komut.Parameters.AddWithValue("@kisi_ID", textBox4.Text);
            komut.Parameters.AddWithValue("@adi", textBox1.Text);
            komut.Parameters.AddWithValue("@soyadi", textBox2.Text);
            komut.Parameters.AddWithValue("@kisiTipi", true || false);


            baglanti.Open();
            komut.ExecuteNonQuery();
            baglanti.Close();

            KisiGetir();


        }

        private void button3_Click(object sender, EventArgs e)
        {

            string sorgu = "DELETE FROM kisi.\"Kisi\" WHERE \"kisi_ID\"=@kisi_ID";
            komut = new NpgsqlCommand(sorgu, baglanti);
            komut.Parameters.AddWithValue("@kisi_ID", Convert.ToInt32(textBox4.Text));

            baglanti.Open();
            komut.ExecuteNonQuery();
            baglanti.Close();
            KisiGetir();

        }

        private void button2_Click(object sender, EventArgs e)
        {

            string sorgu = "UPDATE kisi.\"Kisi\" SET adi=@adi, soyadi=@soyadi, \"kisiTipi\"=@kisiTipi WHERE \"kisi_ID\"=@kisi_ID";
            komut = new NpgsqlCommand(sorgu, baglanti);
            komut.Parameters.AddWithValue("@kisi_ID", Convert.ToInt32(textBox4.Text));
            komut.Parameters.AddWithValue("@adi", textBox1.Text);
            komut.Parameters.AddWithValue("@soyadi", textBox2.Text);
            komut.Parameters.AddWithValue("@kisiTipi", true || false);
            baglanti.Open();
            komut.ExecuteNonQuery();
            baglanti.Close();
            KisiGetir();


        }
    }
}

