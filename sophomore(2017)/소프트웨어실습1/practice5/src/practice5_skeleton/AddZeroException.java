package practice5_skeleton;

import java.io.*;
public class AddZeroException extends Exception {
	String message;
	public void AddZeroException(String message){
		this.message=message;
	}
	public void AddZeroException(){
	}
}
