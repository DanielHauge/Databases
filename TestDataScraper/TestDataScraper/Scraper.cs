using Microsoft.VisualBasic.FileIO;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;

namespace TestDataScraper
{
    class Scraper
    {
        List<string> listofcities;
        Regex regex;
        string cityid;
        string citiesFinal;

        public Scraper()
        {
            using (TextFieldParser cityparser = new TextFieldParser(@"C:\Users\Retro\source\repos\TestDataScraper\TestDataScraper\CitiesFinal.csv"))
            {
                citiesFinal = cityparser.ReadToEnd();
            }
                using (TextFieldParser parser = new TextFieldParser(@"C:\Users\Retro\source\repos\TestDataScraper\TestDataScraper\BookMentions.csv"))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                cityid = "";
                listofcities = new List<string>();
                regex = new Regex("." + cityid + ",.");

                while (!parser.EndOfData)
                {
                    string fields = parser.ReadLine();
                    string[] newData = fields.Split(',');
                    cityid = newData[1];
                    regex = new Regex(".*" + cityid + ",.*");
                    listofcities.Add(regex.Match(citiesFinal).Value);
                }
            }
            foreach (string item in listofcities)
            {
                System.Console.WriteLine(item);
            }
            //string stringarray[] = listofcities.ToArray();
            string[] list = new string[] { listofcities.ToArray().ToString() };
            File.WriteAllLines("C:\\Users\\Retro\\source\\repos\\TestDataScraper\\TestDataScraper\\Cities.csv", listofcities.ToArray());
            System.Console.ReadKey();
        }
    }
}

//Read line of Mentions
//Read second field of that
//find entry in cityFinal
//add entry with data from city final to cities.csv 


//using (TextFieldParser cityparser = new TextFieldParser(@"C:\Users\Retro\source\repos\ConsoleApp2\ConsoleApp2\CitiesFinal.csv"))
//{
//    //parser.TextFieldType = FieldType.Delimited;
//    //parser.SetDelimiters(",");
//    //while (!cityparser.EndOfData)
//    //{
//    //    string cityfields = parser.ReadLine();
//    //    string[] citynewData = fields.Split(',');
//    //    string citydata = citynewData[0];
//    //    if (cityid == citydata)
//    //    {
//    //        listofcities.Add(new City(int.Parse(citynewData[0]), citynewData[1], double.Parse(citynewData[2]), double.Parse(citynewData[3]), citynewData[4], int.Parse(citynewData[5])));
//    //        break;
//    //    }
//    //}
//}