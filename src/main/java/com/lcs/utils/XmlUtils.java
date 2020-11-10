package com.lcs.utils;

import java.io.*;
import java.net.URL;

import jdk.nashorn.internal.runtime.options.OptionTemplate;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.DocumentFactory;
import org.dom4j.io.SAXReader;
import org.dom4j.io.XMLWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

@Component
public class XmlUtils {
	public Document xmlread(String filename) throws IOException {
		System.out.println("XML read utils");
		ClassLoader classLoader = getClass().getClassLoader();
		String[] filepaths = filename.split("/");
		String recursivePath = "";
		for(int i = 1; i < filepaths.length -1; i++){
			recursivePath = recursivePath +"/"+ filepaths[i];
			File filepath = new File(classLoader.getResource(".").getFile() + recursivePath);
			if(!filepath.exists()){
				filepath.mkdir();
			}
		}

		File file = new File(classLoader.getResource(".").getFile() + filename);
		if(!file.exists()){
			file.createNewFile();
			DocumentFactory df = new DocumentFactory();
			Document doc = df.createDocument();
			doc.setXMLEncoding("utf-8");
			return doc;

		}


		try {
			SAXReader reader = new SAXReader();
			reader.setEncoding("UTF-8");
			return reader.read(file);

		} catch (DocumentException e) {
			// TODO Auto-generated catch block
			//failed readin xml to get doc;
			//create an empty new doc.
			System.out.println("[XML Read] Failed to retrieve document, creating a new one");
			DocumentFactory df = new DocumentFactory();
			Document doc = df.createDocument();
			doc.setXMLEncoding("utf-8");
			return doc;
		}
    }
	public void xmlwrite(Document doc,String filename) throws IOException
	{
		ClassLoader classLoader = getClass().getClassLoader();
		int idx = filename.lastIndexOf("/");
		File filepath = new File(classLoader.getResource(".").getFile() + filename.substring(0, idx));
		if(!filepath.exists()){
			filepath.mkdir();
		}
		File file = new File(classLoader.getResource(".").getFile() + filename);
		if(!file.exists()){
			file.createNewFile();
		}

		XMLWriter writer = new XMLWriter(new FileWriter(file));
		writer.write(doc);
    	writer.close();
	}
}
