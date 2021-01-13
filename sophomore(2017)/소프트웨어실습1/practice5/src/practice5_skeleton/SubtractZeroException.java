package practice5_skeleton;

import java.io.*;
public class SubtractZeroException extends Exception {
	String message;
	public void SubtractZeroException(String message){
		this.message=message;
	}
	public void SubtractZeroException(){
	}
}
