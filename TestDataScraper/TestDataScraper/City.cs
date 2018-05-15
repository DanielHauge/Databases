using System;
using System.Collections.Generic;
using System.Text;

namespace TestDataScraper
{
    class City
    {
        int id;
        string name;
        double latitude;
        double longitude;
        string cc;
        int population;

        public City(int id, string name, double latitude, double longitude, string cc, int population)
        {
            this.id = id;
            this.name = name;
            this.latitude = latitude;
            this.longitude = longitude;
            this.cc = cc;
            this.population = population;
        }

        public int Id { get => id; set => id = value; }
        public string Name { get => name; set => name = value; }
        public double Latitude { get => latitude; set => latitude = value; }
        public double Longitude { get => longitude; set => longitude = value; }
        public string Cc { get => cc; set => cc = value; }
        public int Population { get => population; set => population = value; }
    }
}
