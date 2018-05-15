using System;
using System.Collections.Generic;
using System.Text;

namespace TestDataScraper
{
    class Mention
    {
        public int book;
        public int city;
        public int count;

        public Mention(int book, int city, int count)
        {
            this.book = book;
            this.city = city;
            this.count = count;
        }
    }
}
