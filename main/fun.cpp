#include <Rcpp.h>
#include<string>
#include<iostream>
#include <fstream>
#include <stdio.h>

using namespace std;
using namespace Rcpp;



class TextPattern {
private:
  int	pat_len;
  char *pattern;
  int	*next;
  
public:
  
  TextPattern(char *pat)
  {
    pat_len = strlen(pat);
    pattern = new char[pat_len];
    for (int i = 0; i < pat_len; i++)
      pattern[i] = pat[i];
    
    next = new int[pat_len];
    next[0] = -1;
    
    int j = -1;
    int k = 0;
    while (k < pat_len - 1)
    {
      while (j >= 0 && pat[k] != pat[j])
        j = next[j];
      j++;
      k++;
      next[k] = (pat[k] == pat[j] ? next[j] : j);
    }
  }
  
  int firstMatch(char *text)
  {
    int j = 0;
    int k = 0;
    while (text[k]) {
      while (j >= 0 && text[k] != pattern[j]) j = next[j];
      k++;
      j++;
      if (j == pat_len){
        cout <<"Found a match" << endl;
        return k - pat_len;
      } 
    }
    
    return -1;
  }
  
  
  ~TextPattern()
  {
    delete[] pattern;
    delete[] next;
  }
};

/*
// [[Rcpp::export]]
char * setText(char x[]){
  return x;
}*/

// [[Rcpp::export]]
void readingFile(NumericVector x) {
  
  char data[0x2000];
  ifstream inFile("Fragaria_vesca.fasta");
  
  
  
  while (inFile)
  {
    inFile.read(data, 0x2000);
    //cout<< data<<endl;

  }
  cout<<"Done reading file!"<<endl;
  /*
  //Now doing kmp
  char pattern[5] = "ACTG";
  TextPattern * kmp = new TextPattern(pattern);
  
  cout << strlen(data) << endl;
  
  int patternlength = strlen(data)/5;
  char pat1[patternlength], pat2[patternlength], pat3[patternlength], pat4[patternlength], pat5[patternlength];

  cout << kmp->firstMatch(data) << endl;
*/
  //return x *2;
}

