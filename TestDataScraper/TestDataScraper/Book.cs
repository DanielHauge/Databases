using System;
using System.Collections.Generic;
using System.Text;

namespace TestDataScraper
{
    class Book
    {
        public int id;
        public string title;
        public string author;

        public Book(int id, string title, string author)
        {
            this.id = id;
            this.title = title;
            this.author = author;
        }
    }
}
