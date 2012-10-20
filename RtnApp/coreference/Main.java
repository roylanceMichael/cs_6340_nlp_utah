import java.io.File;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import java.util.regex.Pattern;
import java.util.regex.Matcher;

class Main{
	public static void main(String[] args){
		String path = ".";
		
		String regex = ".xml";
                // Step 1: Allocate a Pattern object to compile a regexe
                Pattern pattern = Pattern.compile(regex);
		
                File folder = new File(path);
		File[] listOfFiles = folder.listFiles();
		for(int i = 0; i < listOfFiles.length; i++){
                    String fileName = listOfFiles[i].getName();
                    if(fileName != null){
                        Matcher match = pattern.matcher(fileName);
                        if(match.find()){
                            try{
                                File file = new File(fileName);
                                DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                                DocumentBuilder db = dbf.newDocumentBuilder();
                                Document doc = db.parse(file);
                                // 
                            }
                            catch(Exception e){
                                
                            }
                            
                            
                            System.out.println(fileName);
                        }
                    }
		}
	}
}