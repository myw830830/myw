package com.myw;

import java.util.ArrayList;
import java.util.Random;
import java.util.Scanner;

public class PlayGuess {	
	Scanner cin = new Scanner(System.in);
	
	private static int arrayRange = 10;
	private static ArrayList<Integer> aimNum = new ArrayList<Integer>();	
	private static ArrayList<Integer> guessNum = new ArrayList<Integer>();
	private static int aCount = 0;
	private static int bCount = 0;
	
	private void generateNum(){
		//Generate a new 4 digits number to guess.		
		//Initialize the ArrayList
		ArrayList<Integer> array = new ArrayList<Integer>();
		for(int i = 0; i < 10; i++)
			array.add(i);
		Random random = new Random();
		for(int i = 0; i < 4; i++){
			int singleNumIndex = random.nextInt(arrayRange--);			
			aimNum.add(array.get(singleNumIndex)); 
			array.remove(singleNumIndex);
		}
	}
	
	private void input(int inputNum){
		System.out.println(inputNum);
		for(int i = 0; i < 4; i++){
			guessNum.add(0, inputNum%10);
			inputNum = inputNum/10;
		}
	}
	
	private void output(){
		for(int i = 0; i < 4; i++)
			if(aimNum.get(i) == guessNum.get(i))
				aCount++;
		
		for(int i: aimNum)
			for(int j: guessNum)
				if(i == j)
					bCount++;
		
		bCount -= aCount;		
		System.out.println(aCount + "A" + bCount + "B");
		aCount = 0;
		bCount = 0;
	}
	
	public static void main(String...args){		
		PlayGuess guess = new PlayGuess();
		System.out.println("Welcome to the GuessNum game, enjoy it! ");
		guess.generateNum();
		int counter = 0;
				
		//Test if the guess number equals to the aim number.
		for(int i = 123; i < 9877; i++){
			counter ++;
			guess.input(i);
			guess.output();
			if(aimNum.equals(guessNum)){
				System.out.println("Congratulations! You made it after guessing " + counter + " times!");
				break;
			}
			guessNum.clear();
		}
	}
}
