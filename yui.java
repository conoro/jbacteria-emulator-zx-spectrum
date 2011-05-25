import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.InputStreamReader;
import java.io.IOException;
import java.io.FileOutputStream;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import com.yahoo.platform.yui.compressor.YUICompressor;
public class yui{
  public static String file_get_contents(String file)
    throws FileNotFoundException, IOException{
    java.io.StringWriter sw= new java.io.StringWriter();
    InputStreamReader in= new InputStreamReader (new FileInputStream(file), "UTF-8");
    char[] buffer = new char[4096];
    int n;
    while (-1 != (n= in.read(buffer)))
      sw.write(buffer, 0, n);
    in.close();
    return sw.toString();
  }
  public static void file_put_contents(String file, String contents)
  throws IOException{
    new FileOutputStream(file).write(contents.getBytes("UTF-8"));
  }
  public static void main(String args[])
  throws IOException{
    String enjs= "";
    Pattern p;
    Matcher m;
    String[] lista= file_get_contents("txt/"+args[0]+".txt").split("\n");
    for (int i= 0; i<lista.length; i++)
      enjs+= file_get_contents(lista[i]);
    p= Pattern.compile("\\/\\*\\*\\/(.*)\\/\\*.*\\*\\/");
    m= p.matcher(enjs);
    enjs= m.replaceAll("$1");
    file_put_contents(args[0]+".js", enjs);
    YUICompressor.main(new String[] {"--charset", "utf8", args[0]+".js", "-o", args[0]+".js"});
  }
}