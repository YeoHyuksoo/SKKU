package practice5_skeleton;

public class SimpleCalculator {
		
	public int result;
		public void SimpleCalculator(){
			
		}
		public void add(int num) throws OutOfRangeException, AddZeroException{
			if(result+num>1000 || result+num<0){
				throw new OutOfRangeException();
			}
			if (num==0){
				throw new AddZeroException();
			}
			result=result+num;
		}
		public void subtract(int num) throws OutOfRangeException, SubtractZeroException{
			if(result-num>1000 || result-num<0){
				throw new OutOfRangeException();
			}
			if (num==0){
				throw new SubtractZeroException();
			}
			result=result-num;
		}
		public void print(){
			System.out.println(result);
		}
		public void reset(){
			result=0;
		}
		public int getResult(){
			return result;
		}
		public void setResult(int result){
			this.result=result;
		}
		
	public static void main(String[] args) {
		// TODO Auto-generated method stub

	}

}
