package practice5_skeleton;

import java.io.*;
public class OutOfRangeException extends Exception{
	String message;
	public void OutOfRangeException(String message){
		this.message=message;
	}
	public void OutOfRangeException(){
	}
}
