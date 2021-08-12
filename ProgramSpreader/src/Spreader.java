import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

public class Spreader {
    final static int TURTLECOUNT=6;
    final static int [] TURTLESWHICHGETTESTS={5};
    public static void main(String[] args) {
        File folder= new File("computer\\All");
        for (int i=0;i<TURTLECOUNT;i++){
            File tf=new File("computer\\"+i);
            if (!tf.exists()){
                tf.mkdirs();
            }
            for (File f:folder.listFiles()){
                try {
                    Files.copy(f.toPath(),Path.of("computer\\"+i+"\\"+f.getName()), StandardCopyOption.REPLACE_EXISTING);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }



        folder= new File("computer\\Tests");
        for (int i:TURTLESWHICHGETTESTS){
            File tf=new File("computer\\"+i);
            if (!tf.exists()){
                tf.mkdirs();
            }
            for (File f:folder.listFiles()){
                try {
                    Files.copy(f.toPath(),Path.of("computer\\"+i+"\\"+f.getName()), StandardCopyOption.REPLACE_EXISTING);
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
