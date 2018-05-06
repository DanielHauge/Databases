import org.apache.commons.io.FileUtils;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.*;
import java.text.BreakIterator;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import edu.stanford.nlp.ie.AbstractSequenceClassifier;
import edu.stanford.nlp.ie.crf.*;
import edu.stanford.nlp.ling.CoreLabel;



public class main {

    public static Connection conn;
    public static FileWriter Bookscsv;
    public static FileWriter Mentionscsv;
    public static int index;

    public static void main(String[] args) throws IOException, SQLException, ClassNotFoundException {

        // File stuff
        Bookscsv = new FileWriter("Books.csv", true);
        Mentionscsv = new FileWriter("BookMentions.csv", true);

        String serializedClassifier = "BookParser/classifiers/english.all.3class.distsim.crf.ser.gz";
        AbstractSequenceClassifier<CoreLabel> classifier = CRFClassifier.getClassifier(serializedClassifier);

        // Database stuff
        String jdbcUrl = "jdbc:postgresql://192.168.33.11:5432/postgres";
        String username = "postgres";
        String password = null;
        conn = DriverManager.getConnection(jdbcUrl, username, password);


        // Starting with index 1.
        index = 0;

        // Pattern for regex
        Pattern titlefinder = Pattern.compile("(?<=\\bTitle:\\s)(.*)");
        Pattern authrofinder = Pattern.compile("(?<=\\bAuthor:\\s)(.*)");
        Pattern capital = Pattern.compile("[A-Z][a-z]+");
        //Pattern capitalwords = Pattern.compile("(?<!\\.\\s)\\b[A-Z][a-z]{5,15}\\b"); //old
        Pattern XMLExtractor = Pattern.compile("(?<=<LOCATION>)(.*?)(?=<\\/LOCATION>)");
        Pattern RDFTitleExtractor = Pattern.compile("(?<=<dcterms:title>)(.*?)(?=<\\/dcterms:title>)");
        Pattern RDFAuthorExtractor = Pattern.compile("(?<=<pgterms:name>)(.*?)(?=<\\/pgterms:name>)");





        // CityFinder stuff


        // Itererate over each file in a folder
        File dir = new File("Books/");
        File[] directoryListing = dir.listFiles();
        if (directoryListing != null) {

            // Foreach file in the folder:
            for (File child : directoryListing) {

                // Here it will ensure the ID is not used by cities. This is to not colide with same ID's in neo4j.
                // If it finds an ID that it used, it will skip that id and try the next one.
                index++;
                while (IndexIsInUse(index)){
                    index++;
                }


                // Init vars
                String title = "Unknown";
                String author = "Unknown";
                String book = "";

                //Get file into a long string
                try {
                    book = FileUtils.readFileToString(child, "UTF-8");
                } catch (IOException e) {
                    e.printStackTrace();
                    System.out.println("Something went wrong, could not read book.");
                }








                System.out.println(child.getName());



                // Find title
                Matcher matcher = titlefinder.matcher(book);
                if (matcher.find()){
                    title = matcher.group(0);
                }else{
                    String rdfpath = "pg"+child.getName().split("\\.")[0]+".rdf";
                    String RDF = FileUtils.readFileToString(new File("RDF/"+rdfpath), "UTF-8");
                    Matcher mrdftitle = RDFTitleExtractor.matcher(RDF);
                    if (mrdftitle.find()){
                        title = mrdftitle.group(0);
                    }
                }


                // Find author
                Matcher matcher2 = authrofinder.matcher(book);
                if (matcher2.find()){
                    author = matcher2.group(0);
                }else{
                    String rdfpath = "pg"+child.getName().split("\\.")[0]+".rdf";
                    String RDF = FileUtils.readFileToString(new File("RDF/" + rdfpath), "UTF-8");
                    Matcher mrdfauthor = RDFAuthorExtractor.matcher(RDF);
                    if (mrdfauthor.find()){
                        author = mrdfauthor.group(0);
                        ;
                        while (mrdfauthor.find()){
                            author = author+" & "+mrdfauthor.group(0);
                        }
                    }

                }
                title = title.replace(',', '·');
                title = title.replace('"', ' ');
                author = author.replace(',', '·');
                author = author.replace('"', ' ');


                // Append to books.csv
                Bookscsv.append("\n"+index+","+title+","+author);
                Bookscsv.flush();



                // Find all sentences that have more than 1 capitalized word. Then run that sentence though stanfords naming entity software and add all found locations to a dictionary and also counts up if it has allready seen that occurence.
                Map<String, Integer> list = new HashMap<String, Integer>();
                BreakIterator iterator = BreakIterator.getSentenceInstance(Locale.ENGLISH);
                iterator.setText(book);
                int start = iterator.first();
                ArrayList<String> PotentialCities = new ArrayList<>();

                for (int end = iterator.next(); end != BreakIterator.DONE; start = end, end = iterator.next()) {
                    String sentence = book.substring(start,end);
                    Matcher capitalMatcher = capital.matcher(sentence);
                    int numberofcapwords = 0;
                    while (capitalMatcher.find()){
                        numberofcapwords++;
                    }
                    if (numberofcapwords>1){
                        PotentialCities.add(sentence);
                    }
                }

                for (String str : PotentialCities){
                    String cs = classifier.classifyWithInlineXML(str);
                    Matcher m = XMLExtractor.matcher(cs);
                    while(m.find()){
                        String temp = m.group(0);
                        if (list.get(temp)==null){list.put(temp, 0);}
                        list.put(temp, list.get(temp).intValue()+1);
                    }
                }

                /*
                //OLD

                Map<String, Integer> list = new HashMap<String, Integer>();
                Matcher matcher3 = capitalwords.matcher(book);
                while (matcher3.find()){
                    String temp = matcher3.group(0);
                    if (list.get(temp)==null){list.put(temp, 0);}
                    list.put(temp, list.get(temp).intValue()+1);
                }
                */








                // Now all Potential cities has been found and we now iterate over them
                int finalIndex = index;
                list.forEach((k, v)-> {
                    //System.out.format("key: %s, value: %d%n", k, v);
                    ArrayList<Integer> citiesid = new ArrayList<>();
                    try {
                        // First we need to figure out if that city is in our database, if so. it will return all ID's of that city.
                        citiesid = IsThisACity(k);
                    } catch (SQLException e) {

                        e.printStackTrace();
                    }
                    // If it actully found ID's where it matched the names in the database. It will then append to csv file and flush.
                    if (citiesid.size()!=0){
                        for (Integer integer : citiesid) {
                            try {
                                Mentionscsv.append("\n"+ finalIndex +","+integer+","+v);
                                Mentionscsv.flush();
                            } catch (IOException e) {
                                e.printStackTrace();
                            }
                        }
                    }
                });

                // Renaming the file to the given index we have.
                System.out.println("Done with: "+index);
                child.renameTo(new File("Books/BN-" + index+".txt"));

            }
        } else {
            System.out.println("Uhm, this was not a folder. or Something else went wrong.");
        }



        conn.close();
    }

    private static boolean IndexIsInUse(int index) throws SQLException {
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT COUNT(*) FROM cities WHERE id="+index+";");
        if (rs.next()){
            if (rs.getInt(1)==0){
                // System.out.println("Was not in use");
                stmt.close();
                rs.close();
                return false;
            }
        }
        System.out.println(index+" It was in use.");
        stmt.close();
        rs.close();
        return true;
    }


    private static ArrayList<Integer> IsThisACity(String potentialCity) throws SQLException {
        ArrayList<Integer> result = new ArrayList<>();

        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery("SELECT id FROM cities WHERE lower(name) LIKE '%"+potentialCity.toLowerCase()+"%';");
        if (rs.next()){
            result.add(rs.getInt(1));
        } else{
            //System.out.println(potentialCity+" Was not a city in database");
        }

        rs.close();
        stmt.close();
        return result;
    }


}





/*
Var index = 0

loop start
    Loop
        Check at index ikke er taget fra cities, hvis det er taget, index+1 og check igen
        hvis SELECT COUNT(*) FROM cities WHERE id=index; giver 0. Så er ID'et ikke taget
    End loop når index som ikke er taget af cities er fundet.

    Tag næste bog.
    Scrape Title
    Scrape author

    Append index, title og author til en .csv file kaldet (Books.csv)

    Find alle ord som starter med stort som ikke er starten på en sætning.
    Tag alle de ord som blev fundet med stort og crossreference dem med databasen efter en by.
    Hvis byen findes i databasen, tag dens id og gem den i en liste.
    hvis SELECT ID FROM cities WHERE asciiname LIKE Ord; giver id's gem, hvis den ikke returnere noget. gem den ikke(Må være et navn eller sådan).

    For alle byid's i listen
    Append index, byindex til en .csv file kaldet (BookMentions.csv)

loop end (videre til næste bog)
 */
