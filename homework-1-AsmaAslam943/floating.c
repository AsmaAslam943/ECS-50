/*
 * Standard IO and file routines.
 */

/*
 * You MUST NOT add in any additional #includes below, the autograder will check!
 */
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include "floating.h"

/* This function is designed to provide information about
   the IEEE floating point value passed in.  Note that this
   ONLY works on systems where sizeof(float) == 4.

   For a normal floating point number it it should have a + or -
   depending on the sign bit, then the significand in binary in the
   format of the most significant bit, a decimal point, and then the
   remaining 23 bits, a space, and then the exponent as 2^ and then a
   signed integer.  As an example, the floating point number .5 is
   represented as "+1.00000000000000000000000 2^-1" (without the
   quotation marks).

   There are a couple of special cases: 0 should be "+0" or "-0"
   depending on the sign.  An infinity should be "+INF" or "-INF", and
   a NAN should be "NaN".

   For denormalized numbers, write them with a leading 0. and then the
   bits in the denormalized value.

   It should be safe: The output should be truncated if the buffer is
   not sufficient to include all the data.
*/
char *floating_info(union floating f, char *buf, size_t buflen)
{
  //initialized the sign, exponent and significand of the floating point 
    int sn = (f.as_int >> 31) & 1;  //Sign; We shift to the right by 31 because we have 32 bits and the sign is 1 element 
    int exp = ((f.as_int >> 23) & 0xFF);  //Exponent; we have 23 and the 0xFF because we move by 1 byte but since we moved 1 in the sign then we only move 23 instead of 24 
    int sig = f.as_int & 0x7FFFFF;  //Signficand value 

    
    if (exp == 0xFF) {  //These are for the special cases. If exponent is equal to  0xFF AND the signifcand is 0 then infinite 
        if (sig  == 0) {  
            snprintf(buf, buflen, "%cINF", sn ? '-' : '+'); //This line prints if -INF or +INF because we
        } else {  //Otherwise it's just not a Number aka NaN
            snprintf(buf, buflen, "NaN");
        } 
    } else if (f.as_int == 0x00000000 || f.as_int == 0x80000000) {  //This base case checks for 0 
      if (f.as_int == 0x00000000){ //If f.as_int is fully 0 then we return a positive zero 
        snprintf(buf,buflen, "+0"); 
      } else{ //Otherwise we return a negative zero 
        snprintf(buf,buflen,"-0"); 
      }
    } else {
        char s_buf[26];  //Next we start storing the significand as a binary str
        if (exp ==0){ //if the exponent is equal to 0, set to 0 otherwise 1.
          s_buf[0] = '0'; 
        } else{
          s_buf[0] = '1'; 
        }
        s_buf[1] = '.';  //We convert 2nd element to a decimal 
        for (int i = 0; i < 23; i++) {  //Iterate through the significand's bitwise as i < 23 
           if ((sig & (1 <<(22-i)))){
            s_buf[i+2] = '1'; //If the significand is set to 1, then assign to value of 1
           } else{ //Otherwise, this just gets assigned to 0 
            s_buf[i+2] = '0'; 
           }  //This part of the function basically works by iterating each bit within the significand and it checks which to assign significand bitwise to. 
        }
        s_buf[25] = '\0';  //This is a null terminator for the s_buf to end the string 
        int bias_exp = (exp == 0) ? -126 : exp - 127;  //Adjust exponent with 127 bias if necessary
        snprintf(buf, buflen, "%c%s 2^%d", sn ? '-' : '+', s_buf, bias_exp);  //Format final string into buf
    }
    
    if (buflen > 0) {   //Base case; if the buflen is greater than 0, then we have to implement a null terminator to "end string"
        buf[buflen - 1] = '\0'; 
    }
    return buf;

  
}




/* This function is designed to provide information about
   the 16b IEEE floating point value passed in with the same exact format.  */
char *ieee_16_info(uint16_t f, char *buf, size_t buflen)
{  
  int sn = (f >> 15) & 1; //This is the sign variable since we have 16 bits here we move 15 to the right 
  int exp = ((f >> 10) & 0x1F); //Exponent value; 16 - 1 _ 
  int sig = f & 0x3FF; 

  if (exp == 0x1F){ //Special cases; if exponent is equal to 0x1F and the significand is 0 then we know it's infinite 
    if (sig == 0){
      snprintf(buf, buflen, "%cINF", sn ? '-':'+'); //I implemented a ternary this time to show that the sign can either be neg or positive depending on if significand is 0 or not 
    } else{
      snprintf(buf,buflen, "NaN"); //Otherwise it's not a number 
    }
  } else if (exp == 0){ //If the exponent is equal to 0 AND the significand is 0 then we 
    if (sig == 0){
      snprintf(buf,buflen, "%c0", sn ? '-': '+'); 
    } else{
      char binary[11]; //I used char binary[11] to convert to binary string 
      for (int i = 0; i < 10; i++){//Iterate through the 10 significand values  
        if (sig & (1<<(9-i))){ //Continue to iterate bitwise by 1 to left 
          binary[i] = '1'; //Either assign to 1 or 0 
        } else{
          binary[i] = '0'; 
        }
      }
      binary[10] = '\0'; //This is the null terminator at the end of exp value 
      snprintf(buf,buflen, "%c0.%s 2^-14", sn ? '-':'+', binary); 
    }
  } else{
    char s_buf[13]; //Establish array of 13; indicate beginning element is 1, second element is decimal 
    s_buf[0] = '1'; 
    s_buf[1] ='.'; 
    for (int i = 0; i < 10; i++){//we iterate through 10 bits of significand 
      if (sig & (1<<(9-i))){ //Move 1 to the left and continue iterating in the array 
        s_buf[i+2] = '1'; 
      } else{
        s_buf[i+2] = '0'; 
      }
    }
    s_buf[12]='\0'; //Null terminator 
    int e = exp - 15; 
    snprintf(buf,buflen,"%c%s 2^%d", sn ? '-':'+', s_buf, e); //This works to format final string of the equation that's why we have e as a finalized exponent, sn to finalize size etc 
  }

  if (buflen > 0){ //Bounds checking; if greater than 0 we have to set null terminator to end string
    buf[buflen-1]='\0'; 
  }
  return buf; 

 }

/* This function converts an IEEE 32b floating point value into a 16b
   IEEE floating point value.  As a reminder: The sign bit is 1 bit,
   the exponent is 5 bits (with a bias of 15), and the significand is
   10 bits.

   There are several corner cases you need to make sure to consider:
   a) subnormal
   b) rounding:  We use round-to-even in case of a tie.
   c) rounding increasing the exponent on the significand.
   d) +/- 0, NaNs, +/- infinity.
 */
uint16_t as_ieee_16(union floating f)
{
  bool pos = !(f.as_int & 0x80000000); //Checks if it's positive or negative 
  int32_t val = ((int32_t) ((f.as_int >> 23) & 0xFF)); //This essentially grabs the value of the exponent 
  int32_t exp = val - 127; //This is the updated exponent (named exp) that is being subtracted by 127 to adjust. This is because in single bit floating precision, we subtract by 127. 
  uint32_t sig = (f.as_int) & 0x7FFFFF; //This is the significand (aka the mantissa)

  
  uint32_t m = sig >> 13 | 0x400; //This m function shifts significand by 13 bits --> updated mantissa 
  uint32_t remainder = sig & 0x1FFF; //Remainder basically finds last 13 bits of significand 

 
  bool nonzero = false; //initialize a nonzero 

 
  if(val == 0xFF && sig != 0){ //base case if the exponent is 0xFF (all ones) and signficand is not equal to 0 return 0xFFFF (16 bits) 
    return 0xFFFF; 
  }

  if(exp < -14) { //If exponent is less than -14  then sh basically finds the shift value 
    int sh = -1 * (exp + 14); //This is the shift value we use +14 because of condition exponent is less than -14 

    int missingbit = ((1 << sh) - 1) & sig; //The missing bit formula to see if any bits were "missed" or not counted 
    nonzero = (missingbit != 0); //I used nonzero here so that it could check if nonzero "missingbits" was not zero 

    
    sig = (0x800000 | sig) >> sh; //We update the significand here by (0x80000|sig) --> we add an implicit 1 and shift 
    m = sig >> 13; //This shifts sig by 13 bits within mantissa 
    remainder = sig & 0x1FFF;
    exp = -14; //Sets exponent value to -14 
  }
  if(remainder > 0x1000) { //This m += 1 rounds up if the remainder is greater than 0x10000 
    m += 1;
  }
  

  if(remainder == 0x1000 && ((m & 1) || nonzero)) { //This function also intends to round up if the remainder is equal to 0x1000 andthe mantissa is 1 
    m += 1;
  }
  
  if(m > 0x7FF) { //This part basically rounds up the exponent 
    exp += 1;
    m = m >> 1;
  }

  if(exp > 15) { //If exponent is GREATER than 15 and pos is valid then return 0x7C00 else 0xFC00 
    if (pos){
      return 0x7C00; 
    } else{
      return 0xFC00; 
    }
  }
  
  // Is subnormal
  if(m < 0x400 && exp == -14) {
    int res = (pos ? 0x0 : 0x8000) | (m & 0x3FF);//created a result so that if pos exists even with both m < 0x400 and exp == -14 then 0x0 returned 
    return res; //return final result 
  }
  return (pos? 0x0 : 0x8000) | (m & 0x3FF) | (((exp+ 15) & 0x1F) << 10);


}
