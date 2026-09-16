#include <stdint.h>

#define LED ((uint32_t *)0x40000000)
#define SWITCHES ((uint32_t *)0x40010000)

void delay(uint32_t count)
{
  uint32_t i;
  for(i = 0;i < count ;i++);
}

int main()
{
  uint32_t ledbits = 1;
  uint32_t switches;
  
  while(1)
    {
      switches = *SWITCHES;
      while(ledbits != 0x8000)
        {
          *LED = ledbits;
          ledbits <<= 1;
	  delay(switches);
        }
      while(ledbits != 1)
        {
          *LED = ledbits;
          ledbits >>= 1;
	  delay(switches);
        }
    }
  
  return 0;
}
