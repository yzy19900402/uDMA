#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <boost/python.hpp>


using namespace boost::python;
using namespace std;
namespace bp = boost::python;

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long u64;

typedef struct{
	volatile u32 data[448];
}Vernier_Data;

typedef struct UDMA
{
	volatile u32 UDMA_rst;
	volatile u32 Start_offset_Addr;
	volatile u32 End_offset_Addr;
	volatile u32 UDMA_start;
	volatile u32 UDMA_Warning_THR;
	volatile u32 UDMA_Warning_CAC;
  	volatile u32 Write_Done;
  	volatile u32 Write_addr1;
  	volatile u32 Write_addr2;
	volatile u32 Write_init1;
 	volatile u32 Write_init2;
}UDMA_control;
char buffer[128];
inline void ttyPrint(char* s)
{
	sprintf(buffer,"echo %s > /dev/ttyPS0",s);
	system(buffer);
}

class uDMA{
private:
public:
	unsigned int mem_fd;
	u32 mem_addr;
	u32 byte_length;
	UDMA_control* inst;
	u32 TH_H;
	u32 TH_L;
	int shift_counter;
	uDMA(u32 ctrl_addr,u32 mem_addr)
	{
		mem_fd = open("/dev/mem", O_RDWR);
		inst = (UDMA_control*)mmap(0x00,sizeof(UDMA_control) , PROT_READ | PROT_WRITE, MAP_SHARED, mem_fd, ctrl_addr);
		this->mem_addr = mem_addr;
		inst->Start_offset_Addr = mem_addr;
		inst->End_offset_Addr = mem_addr;
		byte_length = 0;
		inst->UDMA_Warning_THR = 250;
		inst->UDMA_Warning_CAC = 50;
		TH_H = 250;
		TH_L = 50;
	}

	~uDMA()
	{
		munmap(inst,sizeof(UDMA_control));
		close(mem_fd);
	}
	void reset_on()
	{
		inst->UDMA_rst = 1;
	}
	void reset_off()
	{
		inst->UDMA_rst = 0;
	}
	void set_memaddr(u32 mem_addr)
	{	
		this->mem_addr = mem_addr;
		inst->Start_offset_Addr = mem_addr;
		inst->End_offset_Addr = mem_addr + byte_length;
	}
	void set_length(u32 counts, u32 size)
	{
		byte_length = counts * size;
		inst->End_offset_Addr = mem_addr + byte_length;
	}
	void start_on()
	{
		inst->UDMA_start = 1;
	}
	void start_off()
	{
		inst->UDMA_start = 0;
	}
	void set_warning_thres(u32 high,u32 low)
	{		
		inst->UDMA_Warning_THR = high;
		inst->UDMA_Warning_CAC = low;
		TH_H = high;
		TH_L = low;
	}
	int ifDone()
	{
		return inst->Write_Done;
	}
	u32 get_end_addr()
	{
		return inst->End_offset_Addr;
	}
};

BOOST_PYTHON_MODULE(uDMA)
{
	class_<uDMA>("uDMA", init<u32,u32>())
		.def(init<u32,u32>())
		.def("reset_on",&uDMA::reset_on)
		.def("reset_off",&uDMA::reset_off)
		.def("start_on",&uDMA::start_on)
		.def("start_off",&uDMA::start_off)
		.def("set_memaddr",&uDMA::set_memaddr)
		.def("set_length",&uDMA::set_length)
		.def("set_warning_thres",&uDMA::set_warning_thres)
		.def("ifDone",&uDMA::ifDone)
		.def("get_end_addr",&uDMA::get_end_addr)
		.def_readonly("TH_H",&uDMA::TH_H)
		.def_readonly("TH_L",&uDMA::TH_L)
		.def_readonly("LENGTH",&uDMA::byte_length)
		.def_readonly("PHYADDR",&uDMA::mem_addr)
		;
}
