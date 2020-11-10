#include <fstream>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <curand_kernel.h> 
#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <math.h>
#include <iomanip>
#include <afx.h>
#include <time.h>
#include"calRHS.h"
#include"sor3D.h"
#include"initialIntegration.h"
#include "io.h"
using namespace std;
#define weight1 0
#define weight2 0
#define weight 0.8
#define zero 1e-7
#define PI 3.1415926535897932384626433832795
__device__ __host__ void ntoijk(long Xsize,long Ysize,long Zsize,long nout,int* i,int*j,int*k)
{
	int iout,jout,kout;
	if(nout<=Xsize*Ysize-1)
	{
		kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
	}
	if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
	{
		iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
	}
	if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
	{
		kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
	}
	if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
	{
		jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
		iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
		iout=Xsize-2-iout;
		kout=kout+1;
	}
	if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
	{
		iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
		kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
		kout=Zsize-2-kout;
		jout=jout+1;
	}
	if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
	{
		jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
		iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
		kout=Zsize-2-kout;
		iout=iout+1;
	}
	i[0]=iout;j[0]=jout;k[0]=kout;
}
__device__ __host__ bool crosspoint(long Xsize,long Ysize,long Zsize,int iin,int jin,int kin,double k1,double k2,double k3,int* i,int* j,int* k)
{
	int iout,jout,kout;
	double r,x,y,z;
	r=0;x=0;y=0;z=0;
	bool flag=0;
	
	/////case 1, vertical to x-axis
	if(k1==0&&k2!=0&&k3!=0)
	{
		if(iin>=0&&iin<=Xsize-1)
		{
			////four crossing point;y=0;y=max;z=0;z=max;
			r=(0-jin)/k2;y=0;z=kin+k3*r;
			if(z<=Zsize-1&&z>=0&&r!=0&&flag==0)//cross y=0;
			{			
				iout=iin;
				jout=0;
				kout=floor(z+0.5);
				flag=1;
			}
			r=(Ysize-1-jin)/k2;y=Ysize-1;z=kin+k3*r;
			if(z<=Zsize-1&&z>=0&&r!=0&&flag==0)//y=max;
			{
				iout=iin;
				jout=Ysize-1;
				kout=floor(z+0.5);
				flag=1;
			}
			r=(0-kin)/k3;z=0;y=jin+k2*r;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)//z=0;
			{
				
				iout=iin;
				jout=floor(y+0.5);
				kout=0;

				flag=1;
			}
			r=(Zsize-1-kin)/k3;z=Zsize-1;y=jin+k2*r;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)
			{
				iout=iin;
				jout=floor(y+0.5);
				kout=Zsize-1;
				flag=1;
			}
			
		}
		if(iin==Xsize-1||iin==0)
		{
			int jout1=jin;
			int kout1=kin;
			r=(0-jin)/k2;y=0;double z=kin+k3*r;
			bool flag2=0;
			if(z<=Zsize-1&&z>=0&&r!=0&&flag==0)//cross y=0;
			{	if(flag2==0){
				iout=iin;
				jout=0;
				kout=floor(z+0.5);
				flag2=1;
			     }
			    else
			    {
				iout=iin;
				jout1=0;
				kout1=floor(z+0.5);
			    }
			    flag=1;
			}
			r=(Ysize-1-jin)/k2;y=Ysize-1;z=kin+k3*r;
			if(z<=Zsize-1&&z>=0&&r!=0&&flag==0)//y=max;
			{
				if(flag2==0)
				{
					iout=iin;
					jout=Ysize-1;
					kout=floor(z+0.5);
					flag2=1;
				}
				else
				{
					iout=iin;
					jout1=Ysize-1;
					kout1=floor(z+0.5);
				}
				flag=1;
			}
			r=(0-kin)/k3;z=0;y=jin+k2*r;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)//z=0;
			{
				if(flag2==0)
				{
					iout=iin;
					jout=floor(y+0.5);
					kout=0;
					flag2=1;
				}
				else
				{
					iout=iin;
					jout1=floor(y+0.5);
					kout1=0;
				}
				

				flag=1;
			}
			r=(Zsize-1-kin)/k3;z=Zsize-1;y=jin+k2*r;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)
			{
				if(flag2==0)
				{
					iout=iin;
					jout=floor(y+0.5);
					kout=Zsize-1;
					flag2=1;
				}
				else
				{
					iout=iin;
					jout1=floor(y+0.5);
					kout1=Zsize-1;
					
				}				
				flag=1;
			}
			if((jout1-jin)*(jout1-jin)+(kout1-kin)*(kout1-kin)>(jout-jin)*(jout-jin)+(kout-kin)*(kout-kin))
			{
				jout=jout1;kout=kout1;
			}
		}
	}
	///case 2, vertical to y-axis
	if(k1!=0&&k2==0&&k3!=0)
	{
		if(jin>=0&&jin<=Ysize-1)
		{
			////four crossing point
			r=(0-iin)/k1;x=0;z=kin+k3*r;//x=0;
			if(z<=Zsize-1&&z>=0&&flag==0&&r!=0)
			{
				iout=0;
				jout=jin;
				kout=floor(z+0.5);
				flag=1;
			}
			r=(Xsize-1-iin)/k1;x=Xsize-1;z=kin+k3*r;//x=max
			if(z<=Zsize-1&&z>=0&&flag==0&&r!=0)
			{
				iout=Xsize-1;
				jout=jin;
				kout=floor(z+0.5);
				flag=1;
			}
			r=(0-kin)/k3;z=0;x=iin+k1*r;//z=0;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				iout=floor(x+0.5);
				jout=jin;
				kout=0;
				flag=1;
			}
			r=(Zsize-1-kin)/k3;z=Zsize-1;x=iin+k1*r;//z=max;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				iout=floor(x+0.5);
				jout=jin;
				kout=Zsize-1;
				flag=1;
			}
			
		}
		if(jin==0||jin==Ysize-1)
		{
			int iout1=iin;
			int kout1=kin;
			bool flag2=0;
			r=(0-iin)/k1;x=0;z=kin+k3*r;//x=0;
			if(z<=Zsize-1&&z>=0&&flag==0&&r!=0)
			{
				if(flag2==0)
				{
					iout=0;
					jout=jin;
					kout=floor(z+0.5);
					flag2=1;
				}
				else
				{
					iout1=0;
					jout=jin;
					kout1=floor(z+0.5);
				}			
				flag=1;
			}
			r=(Xsize-1-iin)/k1;x=Xsize-1;z=kin+k3*r;//x=max
			if(z<=Zsize-1&&z>=0&&flag==0&&r!=0)
			{
				if(flag2==0)
				{
					iout=Xsize-1;
					jout=jin;
					kout=floor(z+0.5);
					flag2=1;
				}
				else
				{
					iout1=Xsize-1;
					jout=jin;
					kout1=floor(z+0.5);
				}
				flag=1;
			}
			r=(0-kin)/k3;z=0;x=iin+k1*r;//z=0;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				if(flag2==0)
				{
					iout=floor(x+0.5);
					jout=jin;
					kout=0;
					flag2=1;
				}
				else
				{
					iout1=int(x+0.5);
					jout=jin;
					kout1=0;
				}
				flag=1;
			}
			r=(Zsize-1-kin)/k3;z=Zsize-1;x=iin+k1*r;//z=max;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				if(flag2==0)
				{
					iout=floor(x+0.5);
					jout=jin;
					kout=Zsize-1;
					flag2=1;
				}
				else
				{
					iout1=floor(x+0.5);
					jout=jin;
					kout1=Zsize-1;
				}
				flag=1;
			}
			if((iout1-iin)*(iout1-iin)+(kout1-kin)*(kout1-kin)>(iout-iin)*(iout-iin)+(kout-kin)*(kout-kin))
			{
				iout=iout1;kout=kout1;
			}
		}
	}
	///case 3, vertical to z-axis
	if(k1!=0&&k2!=0&&k3==0)
	{
		if(kin>=0&&kin<=Zsize-1)
		{
			////four crossing point
			r=(0-iin)/k1;x=0;y=jin+k2*r;//x=0;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)
			{
			    iout=0;
				jout=floor(y+0.5);
				kout=kin;
				flag=1;
			}
			r=(Xsize-1-iin)/k1;x=Xsize-1;y=jin+k2*r;//x=max;
			if(y<=Ysize-1&&y>=0&&r!=0&&flag==0)
			{
				iout=Xsize-1;
				jout=floor(y+0.5);
				kout=kin;
				flag=1;
			}
			r=(0-jin)/k2;y=0;x=iin+k1*r;//y=0;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				iout=floor(x+0.5);
				jout=0;
				kout=kin;
				flag=1;
			}
			r=(Ysize-1-jin)/k2;y=Ysize-1;x=iin+k1*r;//y=max;
			if(x<=Xsize-1&&x>=0&&flag==0&&r!=0)
			{
				iout=floor(x+0.5);
				jout=Ysize-1;
				kout=kin;
				flag=1;
			}
			
		}
		if(kin==0||kin==Zsize-1)
		{
			int iout1=iin;
			int jout1=jin;
			bool flag2=0;
			r=(0-iin)/k1;x=0;y=jin+k2*r;//x=0;
			if(y<=Ysize-1&&y>=0&&flag==0&&r!=0)
			{
				if(flag2==0)
				{
					iout=0;
					jout=floor(y+0.5);
					kout=kin;
					flag2=1;
				}
				else
				{
					iout1=0;
					jout1=floor(y+0.5);
					kout=kin;
				}
				
				flag=1;
			}
			r=(Xsize-1-iin)/k1;x=Xsize-1;y=jin+k2*r;//x=max;
			if(y<=Ysize-1&&y>=0&&r!=0&&flag==0)
			{
				if(flag2==0)
				{
					iout=Xsize-1;
					jout=floor(y+0.5);
					kout=kin;
					flag2=1;
				}
				else
				{
					iout1=Xsize-1;
					jout1=floor(y+0.5);
					kout=kin;
				}
				flag=1;
			}
			r=(0-jin)/k2;y=0;x=iin+k1*r;//y=0;
			if(x<=Xsize-1&&x>=0&&r!=0&&flag==0)
			{
				if(flag==0)
				{
					iout=floor(x+0.5);
					jout=0;
					kout=kin;
					flag2=1;
				}
				else
				{
					iout1=floor(x+0.5);
					jout1=0;
					kout=kin;
				}
				flag=1;
			}
			r=(Ysize-1-jin)/k2;y=Ysize-1;x=iin+k1*r;//y=max;
			if(x<=Xsize-1&&x>=0&&flag==0&&r!=0)
			{
				if(flag2==0)
				{
					iout=floor(x+0.5);
					jout=Ysize-1;
					kout=kin;
					flag2=1;
				}
				else
				{
					iout1=floor(x+0.5);
					jout1=Ysize-1;
					kout=kin;
				}
				flag=1;
			}
			if((iout1-iin)*(iout1-iin)+(jout1-jin)*(jout1-jin)>(iout-iin)*(iout-iin)+(jout-jin)*(jout-jin))
			{
				iout=iout1;jout=jout1;
			}
		}
	}
	///case 4, vertical to plane IJ
	if(k1==0&&k2==0&&k3!=0&&flag==0)
	{

		if(iin<=Xsize-1&&iin>=0&&jin<=Ysize-1&&jin>=0)
		{
			iout=iin;
			jout=jin;
			if(kin<Zsize/2)
			{
				kout=Zsize-1;
			}
			else
			{
				kout=0;
			}
			
			flag=1;
		}
		
	}
	///case 5, vertical to IK plane
	if(k1==0&&k2!=0&&k3==0&&flag==0)
	{
		if(iin>=0&&iin<=Xsize-1&&kin>=0&&kin<=Zsize-1)
		{
			iout=iin;kout=kin;
			if(jin<Ysize/2)
			{
				jout=Ysize-1;
			}
			else
			{
				jout=0;
			}
			flag=1;
		}
		
	}
	///case 6, vertical to JK plane
	if(k1!=0&&k2==0&&k3==0&&flag==0)
	{
		if(jin>=0&&jin<=Ysize-1&&kin>=0&&kin<=Zsize-1)
		{
			jout=jin;kout=kin;
			if(iin<Xsize/2)
			{
				iout=Xsize-1;
			}
			else
			{
				iout=0;
			}
			flag=1;
		}
	}
	/// case 7, purely inclined
	if(k1!=0&&k2!=0&&k3!=0&&flag==0)
	{
		/// six crossing point
		r=(0-iin)/k1;x=0;y=jin+k2*r;z=kin+k3*r;//x=0
		if(y<=Ysize-1&&y>=0&&z<=Zsize-1&&z>=0&&flag==0&&r!=0)
		{
			iout=0;
			jout=floor(y+0.5);
			kout=floor(z+0.5);
			flag=1;
		}
		r=(Xsize-1-iin)/k1;x=Xsize-1;y=jin+k2*r;z=kin+k3*r;//x=max
		if(y<=Ysize-1&&y>=0&&z<=Zsize-1&&z>=0&&flag==0&&r!=0)
		{
			iout=Xsize-1;
			jout=floor(y+0.5);
			kout=floor(z+0.5);
			flag=1;
		}
		r=(0-jin)/k2;x=iin+k1*r;y=0;z=kin+k3*r;//y=0;
		if(x<=Xsize-1&&x>=0&&z<=Zsize-1&&z>=0&&flag==0&&r!=0)
		{
			iout=floor(x+0.5);
			jout=0;
			kout=floor(z+0.5);
			flag=1;
		}
		r=(Ysize-1-jin)/k2;x=iin+k1*r;y=Ysize-1;z=kin+k3*r;//y=max
		if(x<=Xsize-1&&x>=0&&z<=Zsize-1&&z>=0&&flag==0&&r!=0)
		{
			iout=floor(x+0.5);
			jout=Ysize-1;
			kout=floor(z+0.5);
			flag=1;
		}
		r=(0-kin)/k3;x=iin+k1*r;y=jin+k2*r;z=0;//z=0;
		if(x<=Xsize-1&&x>=0&&y<=Ysize-1&&y>=0&&flag==0&&r!=0)
		{
			iout=floor(x+0.5);
			jout=floor(y+0.5);
			kout=0;
			flag=1;
		}
		r=(Zsize-1-kin)/k3;x=iin+k1*r;y=jin+k2*r;z=Zsize-1;//z=max
		if(x<=Xsize-1&&x>=0&&y<=Ysize-1&&y>=0&&flag==0&&r!=0)
		{
			iout=floor(x+0.5);
			jout=floor(y+0.5);
			kout=Zsize-1;
			flag=1;
		}
		
	}
	if(flag==1)
	{
		i[0]=iout;
		j[0]=jout;
		k[0]=kout;
	}
	else
	{
		i[0]=iin;
		j[0]=jin;
		k[0]=kin;
	}
	return flag;
}
__device__ __host__ bool cross2point(long Xsize,long Ysize,long Zsize,int *iin,int *jin,int *kin,double xin,double yin,double zin,double k1,double k2,double k3,int* iout,int* jout,int* kout)
{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	iin[0]=Xsize;jin[0]=Ysize;kin[0]=Zsize;
	iout[0]=Xsize;jout[0]=Ysize;kout[0]=Zsize;
//	printf("%f %f %f %f",xin,yin,zin,sqrt(xin*xin+yin*yin+zin*zin));
	if(k1==0&&k2!=0&&k3!=0)
	{
		if(xin>=-center_x&&xin<=center_x)
		{
			////four crossing point;y=0;y=max;z=0;z=max;
			double r=(-center_y-yin)/k2;double y1=-center_y;double z1=zin+k3*r;
			r=(center_y-yin)/k2;double y2=center_y;double z2=zin+k3*r;
			r=(-center_z-zin)/k3;double z3=-center_z;double y3=yin+k2*r;
			r=(center_z-zin)/k3;double z4=center_z;double y4=yin+k2*r;
			bool flag=0;
			if(z1<=center_z&&z1>=-center_z&&flag==0)//cross y=0;
			{
				if(flag==0)
				{
					iin[0]=floor(xin+center_x+0.5);
					jin[0]=0;
					kin[0]=floor(z1+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=floor(xin+center_x+0.5);
					jout[0]=0;
					kout[0]=floor(z1+center_z+0.5);
				}
				flag=1;
			}
			if(z2<=center_z&&z2>=-center_z)//y=max;
			{
				if(flag==0)
				{
					iin[0]=floor(xin+center_x+0.5);
					jin[0]=Ysize-1;
					kin[0]=floor(z2+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=floor(xin+center_x+0.5);
					jout[0]=Ysize-1;
					kout[0]=floor(z2+center_z+0.5);
				}
				flag=1;
			}
			if(y3<=center_y&&y3>=-center_y)//z=0;
			{
				if(flag==0)
				{
					iin[0]=floor(xin+center_x+0.5);
					jin[0]=floor(y3+center_y+0.5);
					kin[0]=0;
				}
				if(flag==1)
				{
					iout[0]=floor(xin+center_x+0.5);
					jout[0]=floor(y3+center_y+0.5);
					kout[0]=0;
				}
				flag=1;
			}
			if(y4<=center_y&&y4>=-center_y)
			{
				if(flag==0)
				{
					iin[0]=floor(xin+center_x+0.5);
					jin[0]=floor(y4+center_y+0.5);
					kin[0]=Zsize-1;
				}
				if(flag==1)
				{
					iout[0]=floor(xin+center_x+0.5);
					jout[0]=floor(y4+center_y+0.5);
					kout[0]=Zsize-1;
				}
			}
			//sorting intersection point by in, out order
			if(flag!=0)
			{
				if((jout[0]-jin[0])*k2+(kout[0]-kin[0])*k3<0)
				{
					int temp;
					temp=jin[0];jin[0]=jout[0];jout[0]=temp;
					temp=kin[0];kin[0]=kout[0];kout[0]=temp;
				}
			}
			return true;
		}
	}
	///case 2, vertical to y-axis
	if(k1!=0&&k2==0&&k3!=0)
	{
		if(yin>=-center_y&&yin<=center_y)
		{
			////four crossing point
			double r=(-center_x-xin)/k1;double x1=-center_x;double z1=zin+k3*r;//x=0;
			r=(center_x-xin)/k1;double x2=center_x;double z2=zin+k3*r;//x=max
			r=(-center_z-zin)/k3;double z3=-center_z;double x3=xin+k1*r;//z=0;
			r=(center_z-zin)/k3;double z4=center_z;double x4=xin+k1*r;//z=max;
			bool flag=0;
			if(z1<=center_z&&z1>=-center_z)
			{
				if(flag==0)
				{
					iin[0]=0;
					jin[0]=floor(yin+center_y+0.5);
					kin[0]=floor(z1+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=0;
					jout[0]=floor(yin+center_y+0.5);
					kout[0]=floor(z1+center_z+0.5);
				}
				flag=1;
			}
			if(z2<=center_z&&z2>=-center_z)
			{
				if(flag==0)
				{
					iin[0]=Xsize-1;
					jin[0]=floor(yin+center_y+0.5);
					kin[0]=floor(z2+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=Xsize-1;
					jout[0]=floor(yin+center_y+0.5);
					kout[0]=floor(z2+center_z+0.5);
				}
				flag=1;
			}
			if(x3<=center_x&&x3>=-center_x)
			{
				if(flag==0)
				{
					iin[0]=floor(x3+center_x+0.5);
					jin[0]=floor(yin+center_y+0.5);
					kin[0]=0;
				}
				if(flag==1)
				{
					iout[0]=floor(x3+center_x+0.5);
					jout[0]=floor(yin+center_y+0.5);
					kout[0]=0;
				}
				flag=1;
			}
			if(x4<=center_x&&x4>=-center_x)
			{
				if(flag==0)
				{
					iin[0]=floor(x4+center_x+0.5);
					jin[0]=floor(yin+center_y+0.5);
					kin[0]=Zsize-1;
				}
				if(flag==1)
				{
					iout[0]=floor(x4+center_x+0.5);
					jout[0]=floor(yin+center_y+0.5);
					kout[0]=Zsize-1;
				}
				flag=1;
			}
			//sorting intersection point by in, out order
			if(flag!=0)
			{
				if((iout[0]-iin[0])*k1+(kout[0]-kin[0])*k3<0)
				{
					int temp;
					temp=iin[0];iin[0]=iout[0];iout[0]=temp;
					temp=kin[0];kin[0]=kout[0];kout[0]=temp;
				}
			}
			return true;
		}
	}
	///case 3, vertical to z-axis
	if(k1!=0&&k2!=0&&k3==0)
	{
		if(zin>=-center_z&&zin<=center_z)
		{
			////four crossing point
			double r=(-center_x-xin)/k1;double x1=-center_x;double y1=yin+k2*r;//x=0;
			r=(center_x-xin)/k1;double x2=center_x;double y2=yin+k2*r;//x=max;
			r=(-center_y-zin)/k2;double y3=-center_y;double x3=xin+k1*r;//y=0;
			r=(center_y-zin)/k2;double y4=center_y;double x4=xin+k1*r;//y=max;
			bool flag=0;
			if(y1<=center_y&&y1>=-center_y)
			{
				if(flag==0)
				{
					iin[0]=0;
					jin[0]=floor(y1+center_y+0.5);
					kin[0]=floor(zin+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=0;
					jout[0]=floor(y1+center_y+0.5);
					kout[0]=floor(zin+center_z+0.5);
				}
				flag=1;
			}
			if(y2<=center_y&&y2>=-center_y)
			{
				if(flag==0)
				{
					iin[0]=Xsize-1;
					jin[0]=floor(y2+center_y+0.5);
					kin[0]=floor(zin+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=Xsize-1;
					jout[0]=floor(y2+center_y+0.5);
					kout[0]=floor(zin+center_z+0.5);
				}
				flag=1;
			}
			if(x3<=center_x&&x3>=-center_x)
			{
				if(flag==0)
				{
					iin[0]=floor(x3+center_x+0.5);
					jin[0]=0;
					kin[0]=floor(zin+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=floor(x3+center_x+0.5);
					jout[0]=0;
					kout[0]=floor(zin+center_z+0.5);
				}
				flag=1;
			}
			if(x4<=center_x&&x4>=-center_x)
			{
				if(flag==0)
				{
					iin[0]=floor(x4+center_x+0.5);
					jin[0]=Ysize-1;
					kin[0]=floor(zin+center_z+0.5);
				}
				if(flag==1)
				{
					iout[0]=floor(x4+center_x+0.5);
					jout[0]=Ysize-1;
					kout[0]=floor(zin+center_z+0.5);
				}
				flag=1;
			}
			//sorting intersection point by in, out order
			if(flag!=0)
			{
				if((iout[0]-iin[0])*k1+(jout[0]-jin[0])*k2<0)
				{
					int temp;
					temp=iin[0];iin[0]=iout[0];iout[0]=temp;
					temp=jin[0];jin[0]=jout[0];jout[0]=temp;
				}
			}
			return true;
		}
		
	}
	///case 4, vertical to plane IJ
	if(abs(k1)<zero&&abs(k2)<zero&&abs(k3)>=zero)
	{

		if(xin<=center_x&&xin>=-center_x&&yin<=center_y&&yin>=-center_y)
		{
			iin[0]=floor(xin+center_x+0.5);iout[0]=iin[0];
			jin[0]=floor(yin+center_y+0.5);jout[0]=jin[0];
			if(k3>0)
			{
				kin[0]=0;kout[0]=Zsize-1;
			}
			else{
				kin[0]=Zsize-1;kout[0]=0;
			}
			return true;
		}
		
	}
	///case 5, vertical to IK plane
	if(abs(k1)<zero&&abs(k2)>=zero&&abs(k3)<zero)
	{
		if(xin>=-center_x&&xin<=center_x&&zin>=-center_z&&zin<=center_z)
		{
			iin[0]=floor(xin+center_x+0.5);iout[0]=iin[0];
			kin[0]=floor(zin+center_z+0.5);kout[0]=kin[0];
			if(k2>0)
			{
				jout[0]=Ysize-1;jin[0]=0;
			}
			else
			{
				jin[0]=Ysize-1;jout[0]=0;
			}
			return true;
		}
		
	}
	///case 6, vertical to JK plane
	if(abs(k1)>=zero&&abs(k2)<zero&&abs(k3)<zero)
	{
		if(yin>=-center_y&&yin<center_y&&zin>=-center_z&&zin<=center_z)
		{
			jin[0]=floor(yin+center_y+0.5);jout[0]=jin[0];
			kin[0]=floor(zin+center_z+0.5);kout[0]=kin[0];
			if(k1>0)
			{
				iout[0]=Xsize-1;iin[0]=0;
			}
			else
			{
				iin[0]=Xsize-1;iout[0]=0;
			}
		}
		return true;
	}
	/// case 7, purely inclined
	if(abs(k1)>=zero&&abs(k2)>=zero&&abs(k3)>=zero)
	{
		/// six crossing point
		double r;
		double x1,x2,x3,x4,x5,x6;
		double y1,y2,y3,y4,y5,y6;
		double z1,z2,z3,z4,z5,z6;
		r=(-center_x-xin)/k1;x1=-center_x;y1=yin+k2*r;z1=zin+k3*r;//x=0
		r=(center_x-xin)/k1;x2=center_x;y2=yin+k2*r;z2=zin+k3*r;//x=max
		r=(-center_y-yin)/k2;x3=xin+k1*r;y3=-center_y;z3=zin+k3*r;//y=0;
		r=(center_y-yin)/k2;x4=xin+k1*r;y4=center_y;z4=zin+k3*r;//y=max
		r=(-center_z-zin)/k3;x5=xin+k1*r;y5=yin+k2*r;z5=-center_z;//z=0;
		r=(center_z-zin)/k3;x6=xin+k1*r;y6=yin+k2*r;z6=center_z;//z=max
		bool flag=0;
		if(y1<=center_y&&y1>=-center_y&&z1<=center_z&&z1>=-center_z)
		{
			if(flag==0)
			{
				iin[0]=0;
				jin[0]=floor(y1+center_y+0.5);
				kin[0]=floor(z1+center_z+0.5);
			}
			if(flag==1)
			{
				iout[0]=0;
				jout[0]=floor(y1+center_y+0.5);
				kout[0]=floor(z1+center_z+0.5);
			}
			flag=1;
		}
		if(y2<=center_y&&y2>=-center_y&&z2<=center_z&&z2>=-center_z)
		{
			if(flag==0)
			{
				iin[0]=Xsize-1;
				jin[0]=floor(y2+center_y+0.5);
				kin[0]=floor(z2+center_z+0.5);
			}
			if(flag==1)
			{
				iout[0]=Xsize-1;
				jout[0]=floor(y2+center_y+0.5);
				kout[0]=floor(z2+center_z+0.5);
			}
			flag=1;
		}
		if(x3<=center_x&&x3>=-center_x&&z3<=center_z&&z3>=-center_z)
		{
			if(flag==0)
			{
				iin[0]=floor(x3+center_x+0.5);
				jin[0]=0;
				kin[0]=floor(z3+center_z+0.5);
			}
			if(flag==1)
			{
				iout[0]=floor(x3+center_x+0.5);
				jout[0]=0;
				kout[0]=floor(z3+center_z+0.5);
			}
			flag=1;
		}
		if(x4<=center_x&&x4>=-center_x&&z4<=center_z&&z4>=-center_z)
		{
			if(flag==0)
			{
				iin[0]=floor(x4+center_x+0.5);
				jin[0]=Ysize-1;
				kin[0]=floor(z4+center_z+0.5);
			}
			if(flag==1)
			{
				iout[0]=floor(x4+center_x+0.5);
				jout[0]=Ysize-1;
				kout[0]=floor(z4+center_z+0.5);
			}
			flag=1;
		}
		if(x5<=center_x&&x5>=-center_x&&y5<=center_y&&y5>=-center_y)
		{
			if(flag==0)
			{
				iin[0]=floor(x5+center_x+0.5);
				jin[0]=floor(y5+center_y+0.5);
				kin[0]=0;
			}
			if(flag==1)
			{
				iout[0]=floor(x5+center_x+0.5);
				jout[0]=floor(y5+center_y+0.5);
				kout[0]=0;
			}
			flag=1;
		}
		if(x6<=center_x&&x6>=-center_x&&y6<=center_y&&y6>=-center_y)
		{
			if(flag==0)
			{
				iin[0]=floor(x6+center_x+0.5);
				jin[0]=floor(y6+center_y+0.5);
				kin[0]=Zsize-1;
			}
			if(flag==1)
			{
				iout[0]=floor(x6+center_x+0.5);
				jout[0]=floor(y6+center_y+0.5);
				kout[0]=Zsize-1;
			}
			flag=1;
		}
		//sorting intersection point by in, out order
		if((iout[0]-iin[0])*k1+(jout[0]-jin[0])*k2+(kout[0]-kin[0])*k3<0)
		{
			int temp;
			temp=iin[0];iin[0]=iout[0];iout[0]=temp;
			temp=jin[0];jin[0]=jout[0];jout[0]=temp;
			temp=kin[0];kin[0]=kout[0];kout[0]=temp;
		}
		return true;
	}
	return false;
}
__device__ __host__ bool crosspoint2d(long Xsize,long Ysize,int iin,int jin,double k1,double k2,int *i,int *j)
{
	int iout,jout;bool flag=0;
	if(k1==0&&k2!=0)
	{
		iout=iin;
		if(jin==0)
		{
			jout=Ysize-1;
		}
		else
		{
			jout=0;
		}
		if(iout==0||iout==Xsize-1)
		{
			if(jin<Ysize/2)
			{
				jout=Ysize-1;
			}
			else
			{
				jout=0;
			}
		}
		flag=1;
	}
	if(k1!=0&&k2==0)
	{
		jout=jin;
		if(iin==0)
		{
			iout=Xsize-1;
		}
		else
		{
			iout=0;
		}
		if(jout==0||jout==Ysize-1)
		{
			if(iin<Xsize/2)
			{
				jout=Xsize-1;
			}
			else
			{
				jout=0;
			}
		}
		flag=1;
	}
	if(k1!=0&&k2!=0)
	{
		double r,x,y;
		r=(0-iin)/k1;y=k2*r+jin;
		if(y>=0&&y<=Ysize-1&&r!=0&&flag==0)
		{
			iout=0;
			jout=int(y+0.5);
			flag=1;
		}
		r=(Xsize-1-iin)/k1;y=k2*r+jin;
		if(y>=0&&y<=Ysize-1&&r!=0&&flag==0)
		{
			iout=Xsize-1;
			jout=int(y+0.5);
			flag=1;
		}
		r=(0-jin)/k2;x=k1*r+iin;
		if(x>=0&&x<=Xsize-1&&r!=0&&flag==0)
		{
			jout=0;
			iout=int(x+0.5);
			flag=1;
		}
		r=(Ysize-1-jin)/k2;x=k1*r+iin;
		if(x>=0&&x<=Xsize-1&&r!=0&&flag==0)
		{
			jout=Ysize-1;
			iout=int(x+0.5);
			flag=1;
		}
	}
	if(flag==1)
	{
		i[0]=iout;
		j[0]=jout;
	}
	return flag;
		
}
__device__ __host__ void ntoij2d(long Xsize,long Ysize,int nin,int *i,int *j)
{
	int iin,jin;
	if(nin<=Xsize-1)
	{
		iin=nin;jin=0;
	}
	if(nin>Xsize-1&&nin<=Xsize+Ysize-2)
	{
		iin=Xsize-1;jin=nin-(Xsize-1);
	}
	if(nin>Xsize+Ysize-2&&nin<=2*Xsize+Ysize-3)
	{
		iin=Xsize-1-(nin-(Xsize+Ysize-2));jin=Ysize-1;
	}
	if(nin>2*Xsize+Ysize-3)
	{
		iin=0;jin=Ysize-1-(nin-(2*Xsize+Ysize-3));
	}
	i[0]=iin;
	j[0]=jin;
}
__device__ __host__ void ij2dton(long Xsize,long Ysize,int *n,int i,int j)
{
	if(j==0)
	{
		n[0]=i;
	}
	if(i==Xsize-1)
	{
		n[0]=i+j;
	}
	if(j==Ysize-1)
	{
		n[0]=Xsize-1+Ysize-1+(Xsize-1-i);
	}
	if(i==0&&j!=0)
	{
		n[0]=Xsize-1+Ysize-1+Xsize-1+(Ysize-1-j);
	}
}
__device__ __host__ double bodyIntegralFromCenter(long Xsize,long Ysize,long Zsize,int iin,int jin,int kin,int iout,int jout,int kout,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt)
{
	long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
	double k1,k2,k3;
	ilast=iin;jlast=jin;klast=kin;
	k1=iout-jin;
	k2=jout-jin;
	k3=kout-kin;
	//k1=iout-iin;k2=jout-jin;k3=kout-kin;
	double pint=0;
	bool flag=0;
	do 
	{
		if(ilast<iout)
		{
			inext1=ilast+1;jnext1=jlast;knext1=klast;
		}
		if(ilast==iout)
		{
			inext1=ilast-60000;jnext1=jlast;knext1=klast;
		}
		if(ilast>iout)
		{
			inext1=ilast-1;jnext1=jlast;knext1=klast;
		}
		if(jlast<jout)
		{
			inext2=ilast;jnext2=jlast+1;knext2=klast;
		}
		if(jlast==jout)
		{
			inext2=ilast;jnext2=jlast-60000;knext2=klast;
		}
		if(jlast>jout)
		{
			inext2=ilast;jnext2=jlast-1;knext2=klast;
		}
		if(klast<kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast+1;
		}
		if(klast==kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-60000;
		}
		if(klast>kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-1;
		}
		///determine which one is closer to integration path
		double r,d1,d2,d3,x,y,z;
		r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
		r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
		r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
		//////End of calculation distance///////////////
		//path 1
		flag=0;
		if(d1<=d2&&d1<=d3&&inext1>=0&&inext1<Xsize)
		{
			pint+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			ilast=inext1;
			
			flag=1;
		}
		if(d2<d1&&d2<=d3&&jnext2>=0&&jnext2<Ysize)
		{
			pint+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			jlast=jnext2;
			
			flag=1;
		}
		if(d3<d1&&d3<d2&&knext3>=0&&knext3<Zsize)
		{
			pint+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			klast=knext3;
			
			flag=1;
		}
		if(flag==0)
		{
			printf("Error! Wrong Point Found!\n");
			if(d3<d1&&d3<d2)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext3,jnext3,knext3,inext1,jnext1,knext1,inext2,jnext2,knext2);

			}
			if(d2<d1&&d2<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext2,jnext2,knext2,inext1,jnext1,knext1,inext3,jnext3,knext3);

			}
			if(d1<=d2&&d1<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext1,jnext1,knext1,inext3,jnext3,knext3,inext2,jnext2,knext2);

			}
		}

	} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5&&flag==1);	
	return pint;
}
__device__ __host__ double bodyIntegral(long Xsize,long Ysize,long Zsize,int iin,int jin,int kin,int iout,int jout,int kout,double k1,double k2,double k3,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,int* pcountinner)
{
	    long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
	    ilast=iin;jlast=jin;klast=kin;
		if(k1*(iout-iin)+k2*(jout-jin)+k3*(kout-kin)<0)
		{
			k1=-k1;k2=-k2;k3=-k3;
		}
		//k1=iout-iin;k2=jout-jin;k3=kout-kin;
		double pint=0;
		bool flag=0;
		do 
		{
			if(ilast<iout)
			{
				inext1=ilast+1;jnext1=jlast;knext1=klast;
			}
			if(ilast==iout)
			{
				inext1=ilast-60000;jnext1=jlast;knext1=klast;
			}
			if(ilast>iout)
			{
				inext1=ilast-1;jnext1=jlast;knext1=klast;
			}
			if(jlast<jout)
			{
				inext2=ilast;jnext2=jlast+1;knext2=klast;
			}
			if(jlast==jout)
			{
				inext2=ilast;jnext2=jlast-60000;knext2=klast;
			}
			if(jlast>jout)
			{
				inext2=ilast;jnext2=jlast-1;knext2=klast;
			}
			if(klast<kout)
			{
				inext3=ilast;jnext3=jlast;knext3=klast+1;
			}
			if(klast==kout)
			{
				inext3=ilast;jnext3=jlast;knext3=klast-60000;
			}
			if(klast>kout)
			{
				inext3=ilast;jnext3=jlast;knext3=klast-1;
			}
			///determine which one is closer to integration path
			double r,d1,d2,d3,x,y,z;
			r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
			x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
			d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
			r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
			x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
			d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
			r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
			x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
			d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
			//////End of calculation distance///////////////
			//path 1
			    flag=0;
				if(d1<=d2&&d1<=d3&&inext1>=0&&inext1<Xsize)
				{
					pint+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					ilast=inext1;
					pcountinner[inext1+jnext1*Xsize+knext1*Xsize*Ysize]++;
					flag=1;
				}
				if(d2<d1&&d2<=d3&&jnext2>=0&&jnext2<Ysize)
				{
					pint+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					jlast=jnext2;
					pcountinner[inext2+jnext2*Xsize+knext2*Xsize*Ysize]++;
					flag=1;
				}
				if(d3<d1&&d3<d2&&knext3>=0&&knext3<Zsize)
				{
					pint+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					klast=knext3;
					pcountinner[inext3+jnext3*Xsize+knext3*Xsize*Ysize]++;
					flag=1;
				}
				if(flag==0)
				{
					printf("Error! Wrong Point Found!\n");
					if(d3<d1&&d3<d2)
					{
						printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext3,jnext3,knext3,inext1,jnext1,knext1,inext2,jnext2,knext2);
			
					}
					if(d2<d1&&d2<=d3)
					{
						printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext2,jnext2,knext2,inext1,jnext1,knext1,inext3,jnext3,knext3);
					    
					}
					if(d1<=d2&&d1<=d3)
					{
						printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext1,jnext1,knext1,inext3,jnext3,knext3,inext2,jnext2,knext2);
					    
					}
				}

		} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5&&flag==1);	
		return pint;
}
__device__ __host__ double bodyIntegralInner(long Xsize,long Ysize,long Zsize,int iin,int jin,int kin,int iout,int jout,int kout,double k1,double k2,double k3,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double *p,double*pn)
{
	long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
	ilast=iin;jlast=jin;klast=kin;
	if(k1*(iout-iin)+k2*(jout-jin)+k3*(kout-kin)<0)
	{
		k1=-k1;k2=-k2;k3=-k3;
	}
	//k1=iout-iin;k2=jout-jin;k3=kout-kin;
	double pint=0;
	bool flag=0;
	do 
	{
		if(ilast<iout)
		{
			inext1=ilast+1;jnext1=jlast;knext1=klast;
		}
		if(ilast==iout)
		{
			inext1=ilast-60000;jnext1=jlast;knext1=klast;
		}
		if(ilast>iout)
		{
			inext1=ilast-1;jnext1=jlast;knext1=klast;
		}
		if(jlast<jout)
		{
			inext2=ilast;jnext2=jlast+1;knext2=klast;
		}
		if(jlast==jout)
		{
			inext2=ilast;jnext2=jlast-60000;knext2=klast;
		}
		if(jlast>jout)
		{
			inext2=ilast;jnext2=jlast-1;knext2=klast;
		}
		if(klast<kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast+1;
		}
		if(klast==kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-60000;
		}
		if(klast>kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-1;
		}
		///determine which one is closer to integration path
		double r,d1,d2,d3,x,y,z;
		r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
		r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
		r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
		//////End of calculation distance///////////////
		//path 1
		flag=0;
		if(d1<=d2&&d1<=d3&&inext1>=0&&inext1<Xsize)
		{
			pint+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			ilast=inext1;
			//pcountinner[ilast+jlast*Xsize+klast*Xsize*Ysize]++;
			flag=1;
		}
		if(d2<d1&&d2<=d3&&jnext2>=0&&jnext2<Ysize)
		{
			pint+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			jlast=jnext2;
			
			flag=1;
		}
		if(d3<d1&&d3<d2&&knext3>=0&&knext3<Zsize)
		{
			pint+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			klast=knext3;
			//pcountinner[ilast+jlast*Xsize+klast*Xsize*Ysize]++;
			flag=1;
		}
		if(flag==0)
		{
			printf("Error! Wrong Point Found!\n");
			if(d3<d1&&d3<d2)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext3,jnext3,knext3,inext1,jnext1,knext1,inext2,jnext2,knext2);

			}
			if(d2<d1&&d2<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext2,jnext2,knext2,inext1,jnext1,knext1,inext3,jnext3,knext3);

			}
			if(d1<=d2&&d1<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext1,jnext1,knext1,inext3,jnext3,knext3,inext2,jnext2,knext2);

			}
		}

	} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5&&flag==1);	
	return pint;
}
__device__ __host__ double bodyIntegralInner2(long Xsize,long Ysize,long Zsize,int iin,int jin,int kin,int iout,int jout,int kout,double k1,double k2,double k3,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double *p,double*pn,int*pcountinner)
{
	long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
	ilast=iin;jlast=jin;klast=kin;
	if(k1*(iout-iin)+k2*(jout-jin)+k3*(kout-kin)<0)
	{
		k1=-k1;k2=-k2;k3=-k3;
	}
	//k1=iout-iin;k2=jout-jin;k3=kout-kin;
	double pint=0;
	bool flag=0;
	do 
	{
		if(ilast<iout)
		{
			inext1=ilast+1;jnext1=jlast;knext1=klast;
		}
		if(ilast==iout)
		{
			inext1=ilast-60000;jnext1=jlast;knext1=klast;
		}
		if(ilast>iout)
		{
			inext1=ilast-1;jnext1=jlast;knext1=klast;
		}
		if(jlast<jout)
		{
			inext2=ilast;jnext2=jlast+1;knext2=klast;
		}
		if(jlast==jout)
		{
			inext2=ilast;jnext2=jlast-60000;knext2=klast;
		}
		if(jlast>jout)
		{
			inext2=ilast;jnext2=jlast-1;knext2=klast;
		}
		if(klast<kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast+1;
		}
		if(klast==kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-60000;
		}
		if(klast>kout)
		{
			inext3=ilast;jnext3=jlast;knext3=klast-1;
		}
		///determine which one is closer to integration path
		double r,d1,d2,d3,x,y,z;
		r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
		r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
		r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
		x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
		d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
		//////End of calculation distance///////////////
		//path 1
		flag=0;
		if(d1<=d2&&d1<=d3&&inext1>=0&&inext1<Xsize)
		{
			pint+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			ilast=inext1;
			pcountinner[inext1+jnext1*Xsize+knext1*Xsize*Ysize]++;
			flag=1;
		}
		if(d2<d1&&d2<=d3&&jnext2>=0&&jnext2<Ysize)
		{
			pint+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			jlast=jnext2;
			pcountinner[inext2+jnext2*Xsize+knext2*Xsize*Ysize]++;
			flag=1;
		}
		if(d3<d1&&d3<d2&&knext3>=0&&knext3<Zsize)
		{
			pint+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
			pn[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint;
			klast=knext3;
			pcountinner[inext3+jnext3*Xsize+knext3*Xsize*Ysize]++;
			flag=1;
		}
		if(flag==0)
		{
			printf("Error! Wrong Point Found!\n");
			if(d3<d1&&d3<d2)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext3,jnext3,knext3,inext1,jnext1,knext1,inext2,jnext2,knext2);

			}
			if(d2<d1&&d2<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext2,jnext2,knext2,inext1,jnext1,knext1,inext3,jnext3,knext3);

			}
			if(d1<=d2&&d1<=d3)
			{
				printf("%6.5f %6.5f %6.5f (%02d %02d %02d) (%02d %02d %02d) (%02d %02d %02d)\n(%02d %02d %02d) (%02d %02d %02d)\n",d1,d2,d3,iin,jin,kin,iout,jout,kout,inext1,jnext1,knext1,inext3,jnext3,knext3,inext2,jnext2,knext2);

			}
		}

	} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5&&flag==1);	
	return pint;
}
__global__ void initialIntegration(long Xsize,long Ysize,long Zsize,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* p,double* pn)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	long nout=threadIdx.x+blockIdx.x*blockDim.x;
	while(nout<n)
	{
		int iout,jout,kout;
		ntoijk(Xsize,Ysize,Zsize,nout,&iout,&jout,&kout);
		p[nout]=bodyIntegralFromCenter(Xsize,Ysize,Zsize,Xsize/2,Ysize/2,Zsize/2,iout,jout,kout,deltx,delty,deltz,density,DuDt,DvDt,DwDt);
		nout=nout+blockDim.x*gridDim.x;
	}
}
__global__ void omni3d(long Xsize,long Ysize,long Zsize,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int*pcountinner)
{
	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	long iin,jin,kin,iout,jout,kout,indexin,indexout;
	long nin=blockDim.x*blockIdx.x+threadIdx.x;
	long nout=blockDim.y*blockIdx.y+threadIdx.y;
	while(nin<n&&nout<n)
	{
		long iout,jout,kout;
		long facein,faceout;
		if(nout<=Xsize*Ysize-1)
		{
			kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			faceout=1;
		}
		if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
		{
			iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			faceout=2;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
		{
			kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			faceout=3;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
		{
			jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
			iout=Xsize-2-iout;
			kout=kout+1;
			faceout=4;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
			kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
			kout=Zsize-2-kout;
			jout=jout+1;
			faceout=5;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
			kout=Zsize-2-kout;
			iout=iout+1;
			faceout=6;
		}
		long iin,jin,kin;

		if(nin<=Xsize*Ysize-1)
		{
			kin=0;jin=nin/Xsize;iin=nin-Xsize*jin;
			facein=1;
		}
		if(nin>Xsize*Ysize-1&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1))
		{
			iin=Xsize-1;jin=(nin-Xsize*Ysize)/(Zsize-1);kin=nin-Xsize*Ysize-jin*(Zsize-1)+1;
			facein=2;
		}
		if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
		{
			kin=Zsize-1;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-jin*(Xsize-1);iin=Xsize-2-iin;
			facein=3;
		}
		if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
		{
			jin=0;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
			iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kin*(Xsize-1);
			iin=Xsize-2-iin;
			kin=kin+1;
			facein=4;
		}
		if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			iin=0;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
			kin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jin*(Zsize-2);
			kin=Zsize-2-kin;
			jin=jin+1;
			facein=5;
		}
		if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			jin=Ysize-1;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
			iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kin*(Xsize-2);
			kin=Zsize-2-kin;
			iin=iin+1;
			facein=6;
		}
		long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
		ilast=iin;jlast=jin;klast=kin;					    
		if(nin!=nout&&nin>=0&&nin<n&&nout>=0&&nout<n)
		{
			double k1=iout-iin;
			double k2=jout-jin;
			double k3=kout-kin;
			double l=sqrt(k1*k1+k2*k2+k3*k3);
			k1=k1/l;
			k2=k2/l;
			k3=k3/l;
			//cout<<"indexin: "<<nin<<" indexout:"<<nout<<endl;
			//cout<<'('<<iin<<','<<jin<<','<<kin<<")  "<<'('<<iout<<','<<jout<<','<<kout<<")  "<<endl;
			//log<<"indexin: "<<nin<<" indexout:"<<nout<<endl;
			//log<<'('<<iin<<','<<jin<<','<<kin<<")  "<<'('<<iout<<','<<jout<<','<<kout<<")  "<<endl;
			do 
			{
				if(ilast<iout)
				{
					inext1=ilast+1;jnext1=jlast;knext1=klast;
				}
				if(ilast==iout)
				{
					inext1=ilast-1e6;jnext1=jlast;knext1=klast;
				}
				if(ilast>iout)
				{
					inext1=ilast-1;jnext1=jlast;knext1=klast;
				}
				if(jlast<jout)
				{
					inext2=ilast;jnext2=jlast+1;knext2=klast;
				}
				if(jlast==jout)
				{
					inext2=ilast;jnext2=jlast-1e6;knext2=klast;
				}
				if(jlast>jout)
				{
					inext2=ilast;jnext2=jlast-1;knext2=klast;
				}
				if(klast<kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast+1;
				}
				if(klast==kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast-1e6;
				}
				if(klast>kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast-1;
				}
				///determine which one is closer to longegration path
				double r,d1,d2,d3,x,y,z;
				r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
				r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
				r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
				//////End of calculation distance///////////////
				//path 1
				if(d1<=d2&&d1<=d3)
				{
					pint[nin+nout*n]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					ilast=inext1;

				}
				if(d2<d1&&d2<=d3)
				{
					pint[nin+nout*n]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					jlast=jnext2;
				}
				if(d3<d1&&d3<d2)
				{
					pint[nin+nout*n]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					klast=knext3;
				}
			} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5);
		}
		nin=nin+blockDim.x*gridDim.x;
		nout=nout+blockDim.y*gridDim.y;
	}
	//////End of calculation of pressure increment////////////////

	
	
	
	
}
__global__ void omni3dparallellines(long Xsize,long Ysize,long Zsize,int NoAngles,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount,int* pcountinner)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	long angle=threadIdx.y+blockDim.y*blockIdx.y;
	//for(int theta=0;theta<NoGrid;theta++)
	//{
		//for(int phi=0;phi<NoGrid;phi++)
		//{
			long nin=threadIdx.x+blockDim.x*blockIdx.x;
			while(nin<n&&angle<NoAngles)
			{
						
				//double k1=sinf(float(theta)/NoGrid*PI)*cosf(float(phi)/NoGrid*PI);
				//double k3=sinf(float(theta)/NoGrid*PI)*sinf(float(phi)/NoGrid*PI);
				//double k2=cosf(float(theta)/NoGrid*PI);
				double k1,k2,k3;
				k1=k1_d[angle];
				k2=k2_d[angle];
				k3=k3_d[angle];
				int iin,jin,kin;
				ntoijk(Xsize,Ysize,Zsize,nin,&iin,&jin,&kin);
				int iout,jout,kout;
				long nout=0;
				crosspoint(Xsize,Ysize,Zsize,iin,jin,kin,k1,k2,k3,&iout,&jout,&kout);
				if(iout+jout*Xsize+kout*Xsize*Ysize<Xsize*Ysize*Zsize&&iout+jout*Xsize+kout*Xsize*Ysize>=0)
				{
					nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
				}		
				if(nin!=nout)
				{
					double pint2=bodyIntegral(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,pcountinner);
					//if(pint!=0)
					//{
						pint[nin+nout*n]+=pint2;
						pcount[nin+nout*n]++;
					//}
						//pcountinner[iin+jin*Xsize+kin*Xsize*Ysize]++;
						//pcountinner[iout+jout*Xsize+kout*Xsize*Ysize]++;
					
				}		
				nin+=blockDim.x*gridDim.x;
				//angle+=blockDim.y*gridDim.y;
			}
		//}
	//}
	//__syncthreads();
}
__global__ void omni3dparallellinesEqualSpacing(long Xsize,long Ysize,long Zsize,int NoAngles,float linespacing,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount,int* pcountinner)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	int NoGrid=Xsize;
	if(NoGrid<Ysize)
	{
		NoGrid=Ysize;
	}
	if(NoGrid<Zsize)
	{
		NoGrid=Zsize;
	}
	NoGrid=NoGrid*1.732/linespacing;
	long angle=threadIdx.y+blockDim.y*blockIdx.y;
	
	int point=threadIdx.x+blockDim.x*blockIdx.x;
	//double spacing=sqrt(float(Xsize*Xsize+Ysize*Ysize+Zsize*Zsize))/NoGrid;
	while(point<NoGrid*NoGrid&&angle<NoAngles)
	{
		float xprime=(float(point/NoGrid)-0.5*(NoGrid-1))*linespacing;
		float yprime=(float(point-point/NoGrid*NoGrid)-0.5*(NoGrid-1))*linespacing;
		double k1,k2,k3;
		k1=k1_d[angle];
		k2=k2_d[angle];
		k3=k3_d[angle];
		float theta=acosf(k3);
		float phi=asinf(k2/__sinf(theta));
		if(k1/__sinf(theta)<0)
		{
			phi=-phi+PI;
		}
		float x=xprime*__cosf(theta)*__cosf(phi)-yprime*__sinf(phi);
		float y=xprime*__cosf(theta)*__sinf(phi)+yprime*__cosf(phi);
		float z=-xprime*__sinf(theta);
		
		//float k1=__sinf(theta)*__cosf(phi);
		//float k2=__sinf(theta)*__sinf(phi);
		//float k3=__cosf(theta);
		int iin,jin,kin,iout,jout,kout;
		cross2point(Xsize,Ysize,Zsize,&iin,&jin,&kin,x,y,z,k1,k2,k3,&iout,&jout,&kout);
		int nin,nout;
		if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize)
		{
			nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
			nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
			if(nin!=nout)
			{
				double pincre=bodyIntegral(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,pcountinner);
				pint[nin+nout*n]+=pincre;
				//pcountinner[iin+jin*Xsize+kin*Xsize*Ysize]++;
				//pcountinner[iout+jout*Xsize+kout*Xsize*Ysize]++;
				pcount[nin+nout*n]++;
				pint[nout+nin*n]+=-pincre;
				pcount[nout+nin*n]++;
			}
			
		}
		point+=blockDim.x*gridDim.x;
	}
}
__global__ void omni2dparallellines(long Xsize,long Ysize,long Zsize,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount)
{
	long theta=threadIdx.y+blockDim.y*blockIdx.y;
	int NoGrid=40;
	long nin=threadIdx.x+blockDim.x*blockIdx.x;
	///IJ Plane z=0;
	while(nin<(Xsize-1+Ysize-1)*2&&theta<NoGrid)
	{
		double k1=cosf(float(theta)/NoGrid*PI);
		double k2=sinf(float(theta)/NoGrid*PI);
		int iin,jin,iout,jout,nout;
		ntoij2d(Xsize,Ysize,nin,&iin,&jin);
		crosspoint2d(Xsize,Ysize,iin,jin,k1,k2,&iout,&jout);
		ij2dton(Xsize,Ysize,&nout,iout,jout);
		if(nin!=nout&&iout>=0&&iout<=Xsize-1&&jout<=Ysize-1&&jout>=0)
		{

		}
		////calculate iout,jout,kout;	
	}
}
__global__ void devidecount(long Xsize,long Ysize,long Zsize,double* pint,int* pcount)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	long tid=threadIdx.x+blockDim.x*blockIdx.x;
	while(tid<n*n)
	{
		if(pcount[tid]>1)
		{
			pint[tid]/=pcount[tid];
		}

		tid+=blockDim.x*gridDim.x;
	}
}
__global__ void omni3dvirtual(long Xsize,long Ysize,long Zsize,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount)
{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	//virtual boundary an ellipsoid
	int a=Xsize-1;
	int b=Ysize-1;
	int c=Zsize-1;
	float delttheta=PI/Zsize/2;
	float deltbeta=PI/Xsize/2;
	float xin,yin,zin,xout,yout,zout,k1,k2,k3,x,y,z;
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin,indexout;
	indexin=blockDim.x*blockIdx.x+threadIdx.x;
	float thetain=(indexin/(2*Zsize))*delttheta;
	float betain=(blockDim.x*blockIdx.x+threadIdx.x-2*Zsize*(indexin/(2*Zsize)))*deltbeta;
	indexout=blockDim.y*blockIdx.y+threadIdx.y;
	float thetaout=(indexout/(2*Xsize))*delttheta;
	float betaout=(blockDim.y*blockIdx.y+threadIdx.y-2*Xsize*(indexout/(2*Xsize)))*deltbeta;
	while(indexin<int(PI/delttheta)*int(PI/deltbeta)*2&&indexout<int(PI/delttheta)*int(PI/deltbeta)*2)
	{
		xin=a*sin(thetain)*cos(betain);
		yin=b*sin(thetain)*sin(betain);
		zin=c*cos(thetain);
		xout=a*sin(thetaout)*cos(betaout);
		yout=b*sin(thetaout)*sin(betaout);
		zout=c*cos(thetaout);
		k1=xout-xin;
		k2=yout-yin;
		k3=zout-zin;
		/////case 1, vertical to x-axis
		if(k1==0&&k2!=0&&k3!=0)
		{
			if(xin>=-center_x&&xin<=center_x)
			{
				////four crossing point;y=0;y=max;z=0;z=max;
				double r=(-center_y-yin)/k2;double y1=-center_y;double z1=zin+k3*r;
				r=(center_y-yin)/k2;double y2=center_y;double z2=zin+k3*r;
				r=(-center_z-zin)/k3;double z3=-center_z;double y3=yin+k2*r;
				r=(center_z-zin)/k3;double z4=center_z;double y4=yin+k2*r;
				bool flag=0;
				if(z1<=center_z&&z1>=-center_z&&flag==0)//cross y=0;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=0;
						kin=int(z1+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=0;
						kout=int(z1+center_z+0.5);
					}
					flag=1;
				}
				if(z2<=center_z&&z2>=-center_z)//y=max;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=Ysize-1;
						kin=int(z2+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=Ysize-1;
						kout=int(z2+center_z+0.5);
					}
					flag=1;
				}
				if(y3<=center_y&&y3>=-center_y)//z=0;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=int(y3+center_y+0.5);
						kin=0;
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=int(y3+center_y+0.5);
						kout=0;
					}
					flag=1;
				}
				if(y4<=center_y&&y4>=-center_y)
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=int(y4+center_y+0.5);
						kin=Zsize-1;
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=int(y4+center_y+0.5);
						kout=Zsize-1;
					}
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((jout-jin)*k2+(kout-kin)*k3<0)
					{
						int temp;
						temp=jin;jin=jout;jout=temp;
						temp=kin;kin=kout;kout=temp;
					}
				}
				
			}
		}
		///case 2, vertical to y-axis
		if(k1!=0&&k2==0&&k3!=0)
		{
			if(yin>=-center_y&&yin<=center_y)
			{
				////four crossing point
				double r=(-center_x-xin)/k1;double x1=-center_x;double z1=zin+k3*r;//x=0;
				r=(center_x-xin)/k1;double x2=center_x;double z2=zin+k3*r;//x=max
				r=(-center_z-zin)/k3;double z3=-center_z;double x3=xin+k1*r;//z=0;
				r=(center_z-zin)/k3;double z4=center_z;double x4=xin+k1*r;//z=max;
				bool flag=0;
				if(z1<=center_z&&z1>=-center_z)
				{
					if(flag==0)
					{
						iin=0;
						jin=int(yin+center_y+0.5);
						kin=int(z1+center_z+0.5);
					}
					if(flag==1)
					{
						iout=0;
						jout=int(yin+center_y+0.5);
						kout=int(z1+center_z+0.5);
					}
					flag=1;
				}
				if(z2<=center_z&&z2>=-center_z)
				{
					if(flag==0)
					{
						iin=Xsize-1;
						jin=int(yin+center_y+0.5);
						kin=int(z2+center_z+0.5);
					}
					if(flag==1)
					{
						iout=Xsize-1;
						jout=int(yin+center_y+0.5);
						kout=int(z2+center_z+0.5);
					}
					flag=1;
				}
				if(x3<=center_x&&x3>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x3+center_x+0.5);
						jin=int(yin+center_y+0.5);
						kin=0;
					}
					if(flag==1)
					{
						iout=int(x3+center_x+0.5);
						jout=int(yin+center_y+0.5);
						kout=0;
					}
					flag=1;
				}
				if(x4<=center_x&&x4>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x4+center_x+0.5);
						jin=int(yin+center_y+0.5);
						kin=Zsize-1;
					}
					if(flag==1)
					{
						iout=int(x4+center_x+0.5);
						jout=int(yin+center_y+0.5);
						kout=Zsize-1;
					}
					flag=1;
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((iout-iin)*k1+(kout-kin)*k3<0)
					{
						int temp;
						temp=iin;iin=iout;iout=temp;
						temp=kin;kin=kout;kout=temp;
					}
				}		
			}
		}
		///case 3, vertical to z-axis
		if(k1!=0&&k2!=0&&k3==0)
		{
			if(zin>=-center_z&&zin<=center_z)
			{
				////four crossing point
				double r=(-center_x-xin)/k1;double x1=-center_x;double y1=yin+k2*r;//x=0;
				r=(center_x-xin)/k1;double x2=center_x;double y2=yin+k2*r;//x=max;
				r=(-center_y-zin)/k2;double y3=-center_y;double x3=xin+k1*r;//y=0;
				r=(center_y-zin)/k2;double y4=center_y;double x4=xin+k1*r;//y=max;
				bool flag=0;
				if(y1<=center_y&&y1>=-center_y)
				{
					if(flag==0)
					{
						iin=0;
						jin=int(y1+center_y+0.5);
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=0;
						jout=int(y1+center_y+0.5);
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(y2<=center_y&&y2>=-center_y)
				{
					if(flag==0)
					{
						iin=Xsize-1;
						jin=int(y2+center_y+0.5);
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=Xsize-1;
						jout=int(y2+center_y+0.5);
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(x3<=center_x&&x3>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x3+center_x+0.5);
						jin=0;
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(x3+center_x+0.5);
						jout=0;
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(x4<=center_x&&x4>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x4+center_x+0.5);
						jin=Ysize-1;
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(x4+center_x+0.5);
						jout=Ysize-1;
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((iout-iin)*k1+(jout-jin)*k2<0)
					{
						int temp;
						temp=iin;iin=iout;iout=temp;
						temp=jin;jin=jout;jout=temp;
					}
				}
				
			}
		}
		///case 4, vertical to plane IJ
		if(abs(k1)<zero&&abs(k2)<zero&&abs(k3)>=zero)
		{

			if(xin<=center_x&&xin>=-center_x&&yin<=center_y&&yin>=-center_y)
			{
				iin=int(xin+center_x+0.5);iout=iin;
				jin=int(yin+center_y+0.5);jout=jin;
				if(k3>0)
				{
					kin=0;kout=Zsize-1;
				}
				else{
					kin=Zsize-1;kout=0;
				}

			}
		}
		///case 5, vertical to IK plane
		if(abs(k1)<zero&&abs(k2)>=zero&&abs(k3)<zero)
		{
			if(xin>=-center_x&&xin<=center_x&&zin>=-center_z&&zin<=center_z)
			{
				iin=int(xin+center_x+0.5);iout=iin;
				kin=int(zin+center_z+0.5);kout=kin;
				if(k2>0)
				{
					jout=Ysize-1;jin=0;
				}
				else
				{
					jin=Ysize-1;jout=0;
				}

			}
		}
		///case 6, vertical to JK plane
		if(abs(k1)>=zero&&abs(k2)<zero&&abs(k3)<zero)
		{
			if(yin>=-center_y&&yin<center_y&&zin>=-center_z&&zin<=center_z)
			{
				jin=int(yin+center_y+0.5);jout=jin;
				kin=int(zin+center_z+0.5);kout=kin;
				if(k1>0)
				{
					iout=Xsize-1;iin=0;
				}
				else
				{
					iin=Xsize-1;iout=0;
				}
			}
			
		}
		/// case 7, purely inclined
		if(abs(k1)>=zero&&abs(k2)>=zero&&abs(k3)>=zero)
		{
			/// six crossing point
			double r;
			double x1,x2,x3,x4,x5,x6;
			double y1,y2,y3,y4,y5,y6;
			double z1,z2,z3,z4,z5,z6;
			r=(-center_x-xin)/k1;x1=-center_x;y1=yin+k2*r;z1=zin+k3*r;//x=0
			r=(center_x-xin)/k1;x2=center_x;y2=yin+k2*r;z2=zin+k3*r;//x=max
			r=(-center_y-yin)/k2;x3=xin+k1*r;y3=-center_y;z3=zin+k3*r;//y=0;
			r=(center_y-yin)/k2;x4=xin+k1*r;y4=center_y;z4=zin+k3*r;//y=max
			r=(-center_z-zin)/k3;x5=xin+k1*r;y5=yin+k2*r;z5=-center_z;//z=0;
			r=(center_z-zin)/k3;x6=xin+k1*r;y6=yin+k2*r;z6=center_z;//z=max
			bool flag=0;
			if(y1<=center_y&&y1>=-center_y&&z1<=center_z&&z1>=-center_z)
			{
				if(flag==0)
				{
					iin=0;
					jin=int(y1+center_y+0.5);
					kin=int(z1+center_z+0.5);
				}
				if(flag==1)
				{
					iout=0;
					jout=int(y1+center_y+0.5);
					kout=int(z1+center_z+0.5);
				}
				flag=1;
			}
			if(y2<=center_y&&y2>=-center_y&&z2<=center_z&&z2>=-center_z)
			{
				if(flag==0)
				{
					iin=Xsize-1;
					jin=int(y2+center_y+0.5);
					kin=int(z2+center_z+0.5);
				}
				if(flag==1)
				{
					iout=Xsize-1;
					jout=int(y2+center_y+0.5);
					kout=int(z2+center_z+0.5);
				}
				flag=1;
			}
			if(x3<=center_x&&x3>=-center_x&&z3<=center_z&&z3>=-center_z)
			{
				if(flag==0)
				{
					iin=int(x3+center_x+0.5);
					jin=0;
					kin=int(z3+center_z+0.5);
				}
				if(flag==1)
				{
					iout=int(x3+center_x+0.5);
					jout=0;
					kout=int(z3+center_z+0.5);
				}
				flag=1;
			}
			if(x4<=center_x&&x4>=-center_x&&z4<=center_z&&z4>=-center_z)
			{
				if(flag==0)
				{
					iin=int(x4+center_x+0.5);
					jin=Ysize-1;
					kin=int(z4+center_z+0.5);
				}
				if(flag==1)
				{
					iout=int(x4+center_x+0.5);
					jout=Ysize-1;
					kout=int(z4+center_z+0.5);
				}
				flag=1;
			}
			if(x5<=center_x&&x5>=-center_x&&y5<=center_y&&y5>=-center_y)
			{
				if(flag==0)
				{
					iin=int(x5+center_x+0.5);
					jin=int(y5+center_y+0.5);
					kin=0;
				}
				if(flag==1)
				{
					iout=int(x5+center_x+0.5);
					jout=int(y5+center_y+0.5);
					kout=0;
				}
				flag=1;
			}
			if(x6<=center_x&&x6>=-center_x&&y6<=center_y&&y6>=-center_y)
			{
				if(flag==0)
				{
					iin=int(x6+center_x+0.5);
					jin=int(y6+center_y+0.5);
					kin=Zsize-1;
				}
				if(flag==1)
				{
					iout=int(x6+center_x+0.5);
					jout=int(y6+center_y+0.5);
					kout=Zsize-1;
				}
				flag=1;
			}
			//sorting intersection point by in, out order
			if((iout-iin)*k1+(jout-jin)*k2+(kout-kin)*k3<0)
			{
				int temp;
				temp=iin;iin=temp;iout=temp;
				temp=jin;jin=jout;jout=temp;
				temp=kin;kin=kout;kout=temp;
			}
		}
		//////////////////////////////END OF CALCULATING IN AND OUT POINT ON REAL BOUNDARY////////////////////////////////
		if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize&&(iin-center_x-xin)*(iin-center_x-xout)+(jin-center_y-yin)*(jin-center_y-yout)+(kin-center_z-zin)*(kin-center_z-zout)<0&&(iin+jin+kin+iout+jout+kout)!=0&&!(iin==iout&&jin==jout&&kin==kout))
		{
			int nin,nout;
			long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
			ilast=iin;jlast=jin;klast=kin;	
			nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
			nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
			if(nin!=nout&&nin<n&&nout<n)
			{
				do 
				{
					if(ilast<iout)
					{
						inext1=ilast+1;jnext1=jlast;knext1=klast;
					}
					if(ilast==iout)
					{
						inext1=ilast-1e6;jnext1=jlast;knext1=klast;
					}
					if(ilast>iout)
					{
						inext1=ilast-1;jnext1=jlast;knext1=klast;
					}
					if(jlast<jout)
					{
						inext2=ilast;jnext2=jlast+1;knext2=klast;
					}
					if(jlast==jout)
					{
						inext2=ilast;jnext2=jlast-1e6;knext2=klast;
					}
					if(jlast>jout)
					{
						inext2=ilast;jnext2=jlast-1;knext2=klast;
					}
					if(klast<kout)
					{
						inext3=ilast;jnext3=jlast;knext3=klast+1;
					}
					if(klast==kout)
					{
						inext3=ilast;jnext3=jlast;knext3=klast-1e6;
					}
					if(klast>kout)
					{
						inext3=ilast;jnext3=jlast;knext3=klast-1;
					}
					///determine which one is closer to longegration path
					double r,d1,d2,d3;
					r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
					x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
					d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
					r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
					x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
					d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
					r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
					x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
					d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
					//////End of calculation distance///////////////


					if(d1<=d2&&d1<=d3&&inext1>=0&&inext1<Xsize&&jnext1>=0&&jnext1<Ysize&&knext1>=0&&knext1<Zsize)
					{
						pint[nin+nout*n]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
						ilast=inext1;

					}
					if(d2<d1&&d2<=d3&&inext2<Xsize&&jnext2>=0&&jnext2<Ysize&&knext2>=0&&knext2<Zsize)
					{
						pint[nin+nout*n]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
						jlast=jnext2;
					}
					if(d3<d1&&d3<d2&&inext3<Xsize&&jnext3>=0&&jnext3<Ysize&&knext3>=0&&knext3<Zsize)
					{
						pint[nin+nout*n]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
						klast=knext3;
					}
				} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5);
				pcount[nin+nout*n]++;
			}						
		}		
		indexin=indexin+blockDim.x*gridDim.x;
		indexout=indexout+blockDim.y*gridDim.y;
	}
}
__global__ void omni3virtualgrid(long Xsize,long Ysize,long Zsize,int NoTheta,int NoBeta,long* index,long* ninvir,long *noutvir,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pintvir)
{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	//virtual boundary an ellipsoid
	int a=Xsize-1;
	int b=Ysize-1;
	int c=Zsize-1;
	float delttheta=PI/NoTheta;
	float deltbeta=2*PI/NoBeta;
	float xin,yin,zin,xout,yout,zout,k1,k2,k3,x,y,z;
	//int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin,indexout;
	indexin=blockDim.x*blockIdx.x+threadIdx.x;
	float thetain=(indexin/(NoBeta))*delttheta;
	float betain=(blockDim.x*blockIdx.x+threadIdx.x-NoBeta*(indexin/(NoBeta)))*deltbeta;
	indexout=blockDim.y*blockIdx.y+threadIdx.y;
	float thetaout=(indexout/(NoBeta))*delttheta;
	float betaout=(blockDim.y*blockIdx.y+threadIdx.y-NoBeta*(indexout/(NoBeta)))*deltbeta;
	while(indexin<NoTheta*NoBeta&&indexout<NoTheta*NoBeta)
	{
		xin=a*sin(thetain)*cos(betain);
		yin=b*sin(thetain)*sin(betain);
		zin=c*cos(thetain);
		xout=a*sin(thetaout)*cos(betaout);
		yout=b*sin(thetaout)*sin(betaout);
		zout=c*cos(thetaout);
		k1=xout-xin;
		k2=yout-yin;
		k3=zout-zin;
		/////case 1, vertical to x-axis
		if(k1==0&&k2!=0&&k3!=0)
		{
			if(xin>=-center_x&&xin<=center_x)
			{
				////four crossing point;y=0;y=max;z=0;z=max;
				double r=(-center_y-yin)/k2;double y1=-center_y;double z1=zin+k3*r;
				r=(center_y-yin)/k2;double y2=center_y;double z2=zin+k3*r;
				r=(-center_z-zin)/k3;double z3=-center_z;double y3=yin+k2*r;
				r=(center_z-zin)/k3;double z4=center_z;double y4=yin+k2*r;
				bool flag=0;
				if(z1<=center_z&&z1>=-center_z)//cross y=0;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=0;
						kin=int(z1+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=0;
						kout=int(z1+center_z+0.5);
					}
					flag=1;
				}
				if(z2<=center_z&&z2>=-center_z)//y=max;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=Ysize-1;
						kin=int(z2+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=Ysize-1;
						kout=int(z2+center_z+0.5);
					}
					flag=1;
				}
				if(y3<=center_y&&y3>=-center_y)//z=0;
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=int(y3+center_y+0.5);
						kin=0;
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=int(y3+center_y+0.5);
						kout=0;
					}
					flag=1;
				}
				if(y4<=center_y&&y4>=-center_y)
				{
					if(flag==0)
					{
						iin=int(xin+center_x+0.5);
						jin=int(y4+center_y+0.5);
						kin=Zsize-1;
					}
					if(flag==1)
					{
						iout=int(xin+center_x+0.5);
						jout=int(y4+center_y+0.5);
						kout=Zsize-1;
					}
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((jout-jin)*k2+(kout-kin)*k3<0)
					{
						int temp;
						temp=jin;jin=jout;jout=temp;
						temp=kin;kin=kout;kout=temp;
					}
				}

			}
		}
		///case 2, vertical to y-axis
		if(k1!=0&&k2==0&&k3!=0)
		{
			if(yin>=-center_y&&yin<=center_y)
			{
				////four crossing point
				double r=(-center_x-xin)/k1;double x1=-center_x;double z1=zin+k3*r;//x=0;
				r=(center_x-xin)/k1;double x2=center_x;double z2=zin+k3*r;//x=max
				r=(-center_z-zin)/k3;double z3=-center_z;double x3=xin+k1*r;//z=0;
				r=(center_z-zin)/k3;double z4=center_z;double x4=xin+k1*r;//z=max;
				bool flag=0;
				if(z1<=center_z&&z1>=-center_z)
				{
					if(flag==0)
					{
						iin=0;
						jin=int(yin+center_y+0.5);
						kin=int(z1+center_z+0.5);
					}
					if(flag==1)
					{
						iout=0;
						jout=int(yin+center_y+0.5);
						kout=int(z1+center_z+0.5);
					}
					flag=1;
				}
				if(z2<=center_z&&z2>=-center_z)
				{
					if(flag==0)
					{
						iin=Xsize-1;
						jin=int(yin+center_y+0.5);
						kin=int(z2+center_z+0.5);
					}
					if(flag==1)
					{
						iout=Xsize-1;
						jout=int(yin+center_y+0.5);
						kout=int(z2+center_z+0.5);
					}
					flag=1;
				}
				if(x3<=center_x&&x3>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x3+center_x+0.5);
						jin=int(yin+center_y+0.5);
						kin=0;
					}
					if(flag==1)
					{
						iout=int(x3+center_x+0.5);
						jout=int(yin+center_y+0.5);
						kout=0;
					}
					flag=1;
				}
				if(x4<=center_x&&x4>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x4+center_x+0.5);
						jin=int(yin+center_y+0.5);
						kin=Zsize-1;
					}
					if(flag==1)
					{
						iout=int(x4+center_x+0.5);
						jout=int(yin+center_y+0.5);
						kout=Zsize-1;
					}
					flag=1;
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((iout-iin)*k1+(kout-kin)*k3<0)
					{
						int temp;
						temp=iin;iin=iout;iout=temp;
						temp=kin;kin=kout;kout=temp;
					}
				}		
			}
		}
		///case 3, vertical to z-axis
		if(k1!=0&&k2!=0&&k3==0)
		{
			if(zin>=-center_z&&zin<=center_z)
			{
				////four crossing point
				double r=(-center_x-xin)/k1;double x1=-center_x;double y1=yin+k2*r;//x=0;
				r=(center_x-xin)/k1;double x2=center_x;double y2=yin+k2*r;//x=max;
				r=(-center_y-zin)/k2;double y3=-center_y;double x3=xin+k1*r;//y=0;
				r=(center_y-zin)/k2;double y4=center_y;double x4=xin+k1*r;//y=max;
				bool flag=0;
				if(y1<=center_y&&y1>=-center_y)
				{
					if(flag==0)
					{
						iin=0;
						jin=int(y1+center_y+0.5);
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=0;
						jout=int(y1+center_y+0.5);
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(y2<=center_y&&y2>=-center_y)
				{
					if(flag==0)
					{
						iin=Xsize-1;
						jin=int(y2+center_y+0.5);
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=Xsize-1;
						jout=int(y2+center_y+0.5);
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(x3<=center_x&&x3>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x3+center_x+0.5);
						jin=0;
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(x3+center_x+0.5);
						jout=0;
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				if(x4<=center_x&&x4>=-center_x)
				{
					if(flag==0)
					{
						iin=int(x4+center_x+0.5);
						jin=Ysize-1;
						kin=int(zin+center_z+0.5);
					}
					if(flag==1)
					{
						iout=int(x4+center_x+0.5);
						jout=Ysize-1;
						kout=int(zin+center_z+0.5);
					}
					flag=1;
				}
				//sorting intersection point by in, out order
				if(flag!=0)
				{
					if((iout-iin)*k1+(jout-jin)*k2<0)
					{
						int temp;
						temp=iin;iin=iout;iout=temp;
						temp=jin;jin=jout;jout=temp;
					}
				}

			}
		}
		///case 4, vertical to plane IJ
		if(abs(k1)<zero&&abs(k2)<zero&&abs(k3)>=zero)
		{

			if(xin<=center_x&&xin>=-center_x&&yin<=center_y&&yin>=-center_y)
			{
				iin=int(xin+center_x+0.5);iout=iin;
				jin=int(yin+center_y+0.5);jout=jin;
				if(k3>0)
				{
					kin=0;kout=Zsize-1;
				}
				else{
					kin=Zsize-1;kout=0;
				}

			}
		}
		///case 5, vertical to IK plane
		if(abs(k1)<zero&&abs(k2)>=zero&&abs(k3)<zero)
		{
			if(xin>=-center_x&&xin<=center_x&&zin>=-center_z&&zin<=center_z)
			{
				iin=int(xin+center_x+0.5);iout=iin;
				kin=int(zin+center_z+0.5);kout=kin;
				if(k2>0)
				{
					jout=Ysize-1;jin=0;
				}
				else
				{
					jin=Ysize-1;jout=0;
				}

			}
		}
		///case 6, vertical to JK plane
		if(abs(k1)>=zero&&abs(k2)<zero&&abs(k3)<zero)
		{
			if(yin>=-center_y&&yin<center_y&&zin>=-center_z&&zin<=center_z)
			{
				jin=int(yin+center_y+0.5);jout=jin;
				kin=int(zin+center_z+0.5);kout=kin;
			}
			if(k1>0)
			{
				iout=Xsize-1;iin=0;
			}
			else
			{
				iin=Xsize-1;iout=0;
			}
		}
		/// case 7, purely inclined
		if(abs(k1)>=zero&&abs(k2)>=zero&&abs(k3)>=zero)
		{
			/// six crossing point
			double r;
			double x1,x2,x3,x4,x5,x6;
			double y1,y2,y3,y4,y5,y6;
			double z1,z2,z3,z4,z5,z6;
			r=(-center_x-xin)/k1;x1=-center_x;y1=yin+k2*r;z1=zin+k3*r;//x=0
			r=(center_x-xin)/k1;x2=center_x;y2=yin+k2*r;z2=zin+k3*r;//x=max
			r=(-center_y-yin)/k2;x3=xin+k1*r;y3=-center_y;z3=zin+k3*r;//y=0;
			r=(center_y-yin)/k2;x4=xin+k1*r;y4=center_y;z4=zin+k3*r;//y=max
			r=(-center_z-zin)/k3;x5=xin+k1*r;y5=yin+k2*r;z5=-center_z;//z=0;
			r=(center_z-zin)/k3;x6=xin+k1*r;y6=yin+k2*r;z6=center_z;//z=max
			bool flag=0;
			if(y1<=center_y&&y1>=-center_y&&z1<=center_z&&z1>=-center_z)
			{
				if(flag==0)
				{
					iin=0;
					jin=int(y1+center_y+0.5);
					kin=int(z1+center_z+0.5);
				}
				if(flag==1)
				{
					iout=0;
					jout=int(y1+center_y+0.5);
					kout=int(z1+center_z+0.5);
				}
				flag=1;
			}
			if(y2<=center_y&&y2>=-center_y&&z2<=center_z&&z2>=-center_z)
			{
				if(flag==0)
				{
					iin=Xsize-1;
					jin=int(y2+center_y+0.5);
					kin=int(z2+center_z+0.5);
				}
				if(flag==1)
				{
					iout=Xsize-1;
					jout=int(y2+center_y+0.5);
					kout=int(z2+center_z+0.5);
				}
				flag=1;
			}
			if(x3<=center_x&&x3>=-center_x&&z3<=center_z&&z3>=-center_z)
			{
				if(flag==0)
				{
					iin=int(x3+center_x+0.5);
					jin=0;
					kin=int(z3+center_z+0.5);
				}
				if(flag==1)
				{
					iout=int(x3+center_x+0.5);
					jout=0;
					kout=int(z3+center_z+0.5);
				}
				flag=1;
			}
			if(x4<=center_x&&x4>=-center_x&&z4<=center_z&&z4>=-center_z)
			{
				if(flag==0)
				{
					iin=int(x4+center_x+0.5);
					jin=Ysize-1;
					kin=int(z4+center_z+0.5);
				}
				if(flag==1)
				{
					iout=int(x4+center_x+0.5);
					jout=Ysize-1;
					kout=int(z4+center_z+0.5);
				}
				flag=1;
			}
			if(x5<=center_x&&x5>=-center_x&&y5<=center_y&&y5>=-center_y)
			{
				if(flag==0)
				{
					iin=int(x5+center_x+0.5);
					jin=int(y5+center_y+0.5);
					kin=0;
				}
				if(flag==1)
				{
					iout=int(x5+center_x+0.5);
					jout=int(y5+center_y+0.5);
					kout=0;
				}
				flag=1;
			}
			if(x6<=center_x&&x6>=-center_x&&y6<=center_y&&y6>=-center_y)
			{
				if(flag==0)
				{
					iin=int(x6+center_x+0.5);
					jin=int(y6+center_y+0.5);
					kin=Zsize-1;
				}
				if(flag==1)
				{
					iout=int(x6+center_x+0.5);
					jout=int(y6+center_y+0.5);
					kout=Zsize-1;
				}
				flag=1;
			}
			//sorting intersection point by in, out order
			if((iout-iin)*k1+(jout-jin)*k2+(kout-kin)*k3<0)
			{
				int temp;
				temp=iin;iin=temp;iout=temp;
				temp=jin;jin=jout;jout=temp;
				temp=kin;kin=kout;kout=temp;
			}
		}
		//////////////////////////////END OF CALCULATING IN AND OUT POINT ON REAL BOUNDARY////////////////////////////////
		if((iin-center_x-xin)*(iin-center_x-xout)+(jin-center_y-yin)*(jin-center_y-yout)+(kin-center_z-zin)*(kin-center_z-zout)<0&&(iin+jin+kin+iout+jout+kout)!=0&&!(iin==iout&&jin==jout&&kin==kout))
		{
			long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
			ilast=iin;jlast=jin;klast=kin;					    
			do 
			{
				if(ilast<iout)
				{
					inext1=ilast+1;jnext1=jlast;knext1=klast;
				}
				if(ilast==iout)
				{
					inext1=ilast-1e6;jnext1=jlast;knext1=klast;
				}
				if(ilast>iout)
				{
					inext1=ilast-1;jnext1=jlast;knext1=klast;
				}
				if(jlast<jout)
				{
					inext2=ilast;jnext2=jlast+1;knext2=klast;
				}
				if(jlast==jout)
				{
					inext2=ilast;jnext2=jlast-1e6;knext2=klast;
				}
				if(jlast>jout)
				{
					inext2=ilast;jnext2=jlast-1;knext2=klast;
				}
				if(klast<kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast+1;
				}
				if(klast==kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast-1e6;
				}
				if(klast>kout)
				{
					inext3=ilast;jnext3=jlast;knext3=klast-1;
				}
				///determine which one is closer to longegration path
				double r,d1,d2,d3;
				r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
				r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
				r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
				x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
				d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
				//////End of calculation distance///////////////

				ninvir[indexin+indexout*NoTheta*NoBeta]=index[iin+jin*Xsize+kin*Xsize*Ysize];
				noutvir[indexin+indexout*NoTheta*NoBeta]=index[iout+jout*Xsize+kout*Xsize*Ysize];
				if(d1<=d2&&d1<=d3)
				{
					pintvir[indexin+indexout*NoTheta*NoBeta]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					ilast=inext1;

				}
				if(d2<d1&&d2<=d3)
				{
					pintvir[indexin+indexout*NoTheta*NoBeta]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					jlast=jnext2;
				}
				if(d3<d1&&d3<d2)
				{
					pintvir[indexin+indexout*NoTheta*NoBeta]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
					klast=knext3;
				}
			} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5);
		}

		indexin=indexin+blockDim.x*gridDim.x;
		indexout=indexout+blockDim.y*gridDim.y;
	}
}
__global__ void omni3dvirtual2(long Xsize,long Ysize,long Zsize,long* index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint)
{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	//virtual boundary an ellipsoid
	int a=Xsize-1;
	int b=Ysize-1;
	int c=Zsize-1;
	float delttheta=PI/Zsize/2;
	float deltbeta=PI/Xsize/2;
	float xin,yin,zin,xout,yout,zout,k1,k2,k3,x,y,z;
	double r,d1,d2,d3;
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin;
	indexin=blockDim.x*blockIdx.x+threadIdx.x;
	float thetain=(indexin/(2*Zsize)-1)*delttheta;
	float betain=(blockDim.x*blockIdx.x+threadIdx.x-2*Zsize*(indexin/(2*Zsize))-1)*deltbeta;
	for(float thetaout=0;thetaout<PI;thetaout+=delttheta)
	{
			for(float betaout=0;betaout<2*PI;betaout+=deltbeta)
			{
				xin=a*sin(thetain)*cos(betain);
				yin=b*sin(thetain)*sin(betain);
				zin=c*cos(thetain);
				xout=a*sin(thetaout)*cos(betaout);
				yout=b*sin(thetaout)*sin(betaout);
				zout=c*cos(thetaout);
				k1=xout-xin;
				k2=yout-yin;
				k3=zout-zin;
				/////case 1, vertical to x-axis
				if(k1==0&&k2!=0&&k3!=0)
				{
					if(xin>=-center_x&&xin<=center_x)
					{
						////four crossing point;y=0;y=max;z=0;z=max;
						r=(-center_y-yin)/k2;double y1=-center_y;double z1=zin+k3*r;
						r=(center_y-yin)/k2;double y2=center_y;double z2=zin+k3*r;
						r=(-center_z-zin)/k3;double z3=-center_z;double y3=yin+k2*r;
						r=(center_z-zin)/k3;double z4=center_z;double y4=yin+k2*r;
						bool flag=0;
						if(z1<=center_z&&z1>=-center_z)//cross y=0;
						{
							if(flag==0)
							{
								iin=int(xin+center_x+0.5);
								jin=0;
								kin=int(z1+center_z+0.5);
							}
							if(flag==1)
							{
								iout=int(xin+center_x+0.5);
								jout=0;
								kout=int(z1+center_z+0.5);
							}
							flag=1;
						}
						if(z2<=center_z&&z2>=-center_z)//y=max;
						{
							if(flag==0)
							{
								iin=int(xin+center_x+0.5);
								jin=Ysize-1;
								kin=int(z2+center_z+0.5);
							}
							if(flag==1)
							{
								iout=int(xin+center_x+0.5);
								jout=Ysize-1;
								kout=int(z2+center_z+0.5);
							}
							flag=1;
						}
						if(y3<=center_y&&y3>=-center_y)//z=0;
						{
							if(flag==0)
							{
								iin=int(xin+center_x+0.5);
								jin=int(y3+center_y+0.5);
								kin=0;
							}
							if(flag==1)
							{
								iout=int(xin+center_x+0.5);
								jout=int(y3+center_y+0.5);
								kout=0;
							}
							flag=1;
						}
						if(y4<=center_y&&y4>=-center_y)
						{
							if(flag==0)
							{
								iin=int(xin+center_x+0.5);
								jin=int(y4+center_y+0.5);
								kin=Zsize-1;
							}
							if(flag==1)
							{
								iout=int(xin+center_x+0.5);
								jout=int(y4+center_y+0.5);
								kout=Zsize-1;
							}
						}
						//sorting intersection point by in, out order
						if(flag!=0)
						{
							if((jout-jin)*k2+(kout-kin)*k3<0)
							{
								int temp;
								temp=jin;jin=jout;jout=temp;
								temp=kin;kin=kout;kout=temp;
							}
						}
						
					}
				}
				///case 2, vertical to y-axis
				if(k1!=0&&k2==0&&k3!=0)
				{
					if(yin>=-center_y&&yin<=center_y)
					{
						////four crossing point
						r=(-center_x-xin)/k1;double x1=-center_x;double z1=zin+k3*r;//x=0;
						r=(center_x-xin)/k1;double x2=center_x;double z2=zin+k3*r;//x=max
						r=(-center_z-zin)/k3;double z3=-center_z;double x3=xin+k1*r;//z=0;
						r=(center_z-zin)/k3;double z4=center_z;double x4=xin+k1*r;//z=max;
						bool flag=0;
						if(z1<=center_z&&z1>=-center_z)
						{
							if(flag==0)
							{
								iin=0;
								jin=int(yin+center_y+0.5);
								kin=int(z1+center_z+0.5);
							}
							if(flag==1)
							{
								iout=0;
								jout=int(yin+center_y+0.5);
								kout=int(z1+center_z+0.5);
							}
							flag=1;
						}
						if(z2<=center_z&&z2>=-center_z)
						{
							if(flag==0)
							{
								iin=Xsize-1;
								jin=int(yin+center_y+0.5);
								kin=int(z2+center_z+0.5);
							}
							if(flag==1)
							{
								iout=Xsize-1;
								jout=int(yin+center_y+0.5);
								kout=int(z2+center_z+0.5);
							}
							flag=1;
						}
						if(x3<=center_x&&x3>=-center_x)
						{
							if(flag==0)
							{
								iin=int(x3+center_x+0.5);
								jin=int(yin+center_y+0.5);
								kin=0;
							}
							if(flag==1)
							{
								iout=int(x3+center_x+0.5);
								jout=int(yin+center_y+0.5);
								kout=0;
							}
							flag=1;
						}
						if(x4<=center_x&&x4>=-center_x)
						{
							if(flag==0)
							{
								iin=int(x4+center_x+0.5);
								jin=int(yin+center_y+0.5);
								kin=Zsize-1;
							}
							if(flag==1)
							{
								iout=int(x4+center_x+0.5);
								jout=int(yin+center_y+0.5);
								kout=Zsize-1;
							}
							flag=1;
						}
						//sorting intersection point by in, out order
						if(flag!=0)
						{
							if((iout-iin)*k1+(kout-kin)*k3<0)
							{
								int temp;
								temp=iin;iin=iout;iout=temp;
								temp=kin;kin=kout;kout=temp;
							}
						}
						
					}
				}
				///case 3, vertical to z-axis
				if(k1!=0&&k2!=0&&k3==0)
				{
					if(zin>=-center_z&&zin<=center_z)
					{
						////four crossing point
						r=(-center_x-xin)/k1;double x1=-center_x;double y1=yin+k2*r;//x=0;
						r=(center_x-xin)/k1;double x2=center_x;double y2=yin+k2*r;//x=max;
						r=(-center_y-zin)/k2;double y3=-center_y;double x3=xin+k1*r;//y=0;
						r=(center_y-zin)/k2;double y4=center_y;double x4=xin+k1*r;//y=max;
						bool flag=0;
						if(y1<=center_y&&y1>=-center_y)
						{
							if(flag==0)
							{
								iin=0;
								jin=int(y1+center_y+0.5);
								kin=int(zin+center_z+0.5);
							}
							if(flag==1)
							{
								iout=0;
								jout=int(y1+center_y+0.5);
								kout=int(zin+center_z+0.5);
							}
							flag=1;
						}
						if(y2<=center_y&&y2>=-center_y)
						{
							if(flag==0)
							{
								iin=Xsize-1;
								jin=int(y2+center_y+0.5);
								kin=int(zin+center_z+0.5);
							}
							if(flag==1)
							{
								iout=Xsize-1;
								jout=int(y2+center_y+0.5);
								kout=int(zin+center_z+0.5);
							}
							flag=1;
						}
						if(x3<=center_x&&x3>=-center_x)
						{
							if(flag==0)
							{
								iin=int(x3+center_x+0.5);
								jin=0;
								kin=int(zin+center_z+0.5);
							}
							if(flag==1)
							{
								iout=int(x3+center_x+0.5);
								jout=0;
								kout=int(zin+center_z+0.5);
							}
							flag=1;
						}
						if(x4<=center_x&&x4>=-center_x)
						{
							if(flag==0)
							{
								iin=int(x4+center_x+0.5);
								jin=Ysize-1;
								kin=int(zin+center_z+0.5);
							}
							if(flag==1)
							{
								iout=int(x4+center_x+0.5);
								jout=Ysize-1;
								kout=int(zin+center_z+0.5);
							}
							flag=1;
						}
						//sorting intersection point by in, out order
						if(flag!=0)
						{
							if((iout-iin)*k1+(jout-jin)*k2<0)
							{
								int temp;
								temp=iin;iin=iout;iout=temp;
								temp=jin;jin=jout;jout=temp;
							}
						}
						
					}
				}
				///case 4, vertical to plane IJ
				if(abs(k1)<zero&&abs(k2)<zero&&abs(k3)>=zero)
				{

					if(xin<=center_x&&xin>=-center_x&&yin<=center_y&&yin>=-center_y)
					{
						iin=int(xin+center_x+0.5);iout=iin;
						jin=int(yin+center_y+0.5);jout=jin;
						if(k3>0)
						{
							kin=0;kout=Zsize-1;
						}
						else{
							kin=Zsize-1;kout=0;
						}

					}
				}
				///case 5, vertical to IK plane
				if(abs(k1)<zero&&abs(k2)>=zero&&abs(k3)<zero)
				{
					if(xin>=-center_x&&xin<=center_x&&zin>=-center_z&&zin<=center_z)
					{
						iin=int(xin+center_x+0.5);iout=iin;
						kin=int(zin+center_z+0.5);kout=kin;
						if(k2>0)
						{
							jout=Ysize-1;jin=0;
						}
						else
						{
							jin=Ysize-1;jout=0;
						}

					}
				}
				///case 6, vertical to JK plane
				if(abs(k1)>=zero&&abs(k2)<zero&&abs(k3)<zero)
				{
					if(yin>=-center_y&&yin<center_y&&zin>=-center_z&&zin<=center_z)
					{
						jin=int(yin+center_y+0.5);jout=jin;
						kin=int(zin+center_z+0.5);kout=kin;
					}
					if(k1>0)
					{
						iout=Xsize-1;iin=0;
					}
					else
					{
						iin=Xsize-1;iout=0;
					}
				}
				/// case 7, purely inclined
				if(abs(k1)>=zero&&abs(k2)>=zero&&abs(k3)>=zero)
				{
					/// six crossing point
					double x1,x2,x3,x4,x5,x6;
					double y1,y2,y3,y4,y5,y6;
					double z1,z2,z3,z4,z5,z6;
					r=(-center_x-xin)/k1;x1=-center_x;y1=yin+k2*r;z1=zin+k3*r;//x=0
					r=(center_x-xin)/k1;x2=center_x;y2=yin+k2*r;z2=zin+k3*r;//x=max
					r=(-center_y-yin)/k2;x3=xin+k1*r;y3=-center_y;z3=zin+k3*r;//y=0;
					r=(center_y-yin)/k2;x4=xin+k1*r;y4=center_y;z4=zin+k3*r;//y=max
					r=(-center_z-zin)/k3;x5=xin+k1*r;y5=yin+k2*r;z5=-center_z;//z=0;
					r=(center_z-zin)/k3;x6=xin+k1*r;y6=yin+k2*r;z6=center_z;//z=max
					bool flag=0;
					if(y1<=center_y&&y1>=-center_y&&z1<=center_z&&z1>=-center_z)
					{
						if(flag==0)
						{
							iin=0;
							jin=int(y1+center_y+0.5);
							kin=int(z1+center_z+0.5);
						}
						if(flag==1)
						{
							iout=0;
							jout=int(y1+center_y+0.5);
							kout=int(z1+center_z+0.5);
						}
						flag=1;
					}
					if(y2<=center_y&&y2>=-center_y&&z2<=center_z&&z2>=-center_z)
					{
						if(flag==0)
						{
							iin=Xsize-1;
							jin=int(y2+center_y+0.5);
							kin=int(z2+center_z+0.5);
						}
						if(flag==1)
						{
							iout=Xsize-1;
							jout=int(y2+center_y+0.5);
							kout=int(z2+center_z+0.5);
						}
						flag=1;
					}
					if(x3<=center_x&&x3>=-center_x&&z3<=center_z&&z3>=-center_z)
					{
						if(flag==0)
						{
							iin=int(x3+center_x+0.5);
							jin=0;
							kin=int(z3+center_z+0.5);
						}
						if(flag==1)
						{
							iout=int(x3+center_x+0.5);
							jout=0;
							kout=int(z3+center_z+0.5);
						}
						flag=1;
					}
					if(x4<=center_x&&x4>=-center_x&&z4<=center_z&&z4>=-center_z)
					{
						if(flag==0)
						{
							iin=int(x4+center_x+0.5);
							jin=Ysize-1;
							kin=int(z4+center_z+0.5);
						}
						if(flag==1)
						{
							iout=int(x4+center_x+0.5);
							jout=Ysize-1;
							kout=int(z4+center_z+0.5);
						}
						flag=1;
					}
					if(x5<=center_x&&x5>=-center_x&&y5<=center_y&&y5>=-center_y)
					{
						if(flag==0)
						{
							iin=int(x5+center_x+0.5);
							jin=int(y5+center_y+0.5);
							kin=0;
						}
						if(flag==1)
						{
							iout=int(x5+center_x+0.5);
							jout=int(y5+center_y+0.5);
							kout=0;
						}
						flag=1;
					}
					if(x6<=center_x&&x6>=-center_x&&y6<=center_y&&y6>=-center_y)
					{
						if(flag==0)
						{
							iin=int(x6+center_x+0.5);
							jin=int(y6+center_y+0.5);
							kin=Zsize-1;
						}
						if(flag==1)
						{
							iout=int(x6+center_x+0.5);
							jout=int(y6+center_y+0.5);
							kout=Zsize-1;
						}
						flag=1;
					}
					//sorting intersection point by in, out order
					if((iout-iin)*k1+(jout-jin)*k2+(kout-kin)*k3<0)
					{
						int temp;
						temp=iin;iin=temp;iout=temp;
						temp=jin;jin=jout;jout=temp;
						temp=kin;kin=kout;kout=temp;
					}
				}
				//////////////////////////////END OF CALCULATING IN AND OUT POINT ON REAL BOUNDARY////////////////////////////////
				if((iin-center_x-xin)*(iin-center_x-xout)+(jin-center_y-yin)*(jin-center_y-yout)+(kin-center_z-zin)*(kin-center_z-zout)<0&&(iin+jin+kin+iout+jout+kout)!=0&&!(iin==iout&&jin==jout&&kin==kout))
				{
					long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
					ilast=iin;jlast=jin;klast=kin;					    
					do 
					{
						if(ilast<iout)
						{
							inext1=ilast+1;jnext1=jlast;knext1=klast;
						}
						if(ilast==iout)
						{
							inext1=ilast-1e6;jnext1=jlast;knext1=klast;
						}
						if(ilast>iout)
						{
							inext1=ilast-1;jnext1=jlast;knext1=klast;
						}
						if(jlast<jout)
						{
							inext2=ilast;jnext2=jlast+1;knext2=klast;
						}
						if(jlast==jout)
						{
							inext2=ilast;jnext2=jlast-1e6;knext2=klast;
						}
						if(jlast>jout)
						{
							inext2=ilast;jnext2=jlast-1;knext2=klast;
						}
						if(klast<kout)
						{
							inext3=ilast;jnext3=jlast;knext3=klast+1;
						}
						if(klast==kout)
						{
							inext3=ilast;jnext3=jlast;knext3=klast-1e6;
						}
						if(klast>kout)
						{
							inext3=ilast;jnext3=jlast;knext3=klast-1;
						}
						///determine which one is closer to longegration path
						r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
						x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
						d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
						r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
						x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
						d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
						r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
						x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
						d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
						//////End of calculation distance///////////////
						int nin,nout;
						nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
						nout=index[iout+jout*Xsize*kout*Xsize*Ysize];
						if(d1<=d2&&d1<=d3)
						{
							pint[nin+nout*n]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
							ilast=inext1;

						}
						if(d2<d1&&d2<=d3)
						{
							pint[nin+nout*n]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
							jlast=jnext2;
						}
						if(d3<d1&&d3<d2)
						{
							pint[nin+nout*n]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
							klast=knext3;
						}
					} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5);
				}
				
		}
		
	}
}
__global__ void BCiteration(long Xsize,long Ysize,long Zsize,double* pint,int *pcount,double *p,double* pn,int itrNo)
{

	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin,indexout;
	long nout=blockDim.x*blockIdx.x+threadIdx.x;
	for(int iteration=0;iteration<itrNo;iteration++)
	{
		nout=blockDim.x*blockIdx.x+threadIdx.x;
		pcount[nout]=0;
		while(nout<n)
		{
			if(nout<=Xsize*Ysize-1)
			{
				kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			}
			if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
				iout=Xsize-2-iout;
				kout=kout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
				kout=Zsize-2-kout;
				jout=jout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
				kout=Zsize-2-kout;
				iout=iout+1;
			}
			pn[iout+jout*Xsize+kout*Xsize*Ysize]=0;
			for(int nin=0;nin<n;nin++)
			{
				if(nin<=Xsize*Ysize-1)
				{
					kin=0;jin=nin/Xsize;iin=nin-Xsize*jin;
				}
				if(nin>Xsize*Ysize-1&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1))
				{
					iin=Xsize-1;jin=(nin-Xsize*Ysize)/(Zsize-1);kin=nin-Xsize*Ysize-jin*(Zsize-1)+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
				{
					kin=Zsize-1;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-jin*(Xsize-1);iin=Xsize-2-iin;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
				{
					jin=0;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
					iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kin*(Xsize-1);
					iin=Xsize-2-iin;
					kin=kin+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
				{
					iin=0;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
					kin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jin*(Zsize-2);
					kin=Zsize-2-kin;
					jin=jin+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
				{
					jin=Ysize-1;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
					iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kin*(Xsize-2);
					kin=Zsize-2-kin;
					iin=iin+1;
				}
				///////////
				if(pint[nin+nout*n]!=0)
				{
					pn[iout+jout*Xsize+kout*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+0.5*(pint[nin+nout*n]-pint[nout+nin*n]);
					pcount[nout]++;
				}
			}
			
			pn[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize]/pcount[nout];
			pcount[nout]=0;
			//p[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize];
			
			//pn[iout+jout*Xsize+kout*Xsize*Ysize]=0;
			nout=nout+blockDim.x*gridDim.x;
			//nin=nin+blockDim.y*gridDim.y;

		}
		__syncthreads();
		nout=blockDim.x*blockIdx.x+threadIdx.x;
		pcount[nout]=0;
		while(nout<n)
		{
			if(nout<=Xsize*Ysize-1)
			{
				kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			}
			if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
				iout=Xsize-2-iout;
				kout=kout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
				kout=Zsize-2-kout;
				jout=jout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
				kout=Zsize-2-kout;
				iout=iout+1;
			}
			p[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize];
			nout=nout+blockDim.x*gridDim.x;
		}
	}
	
	
}
__global__ void omni3dparallellinesESInner(long Xsize,long Ysize,long Zsize,int NoAngles,float linespacing,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double*p,double*pn)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	long angle=threadIdx.y+blockDim.y*blockIdx.y;
	int NoGrid=Xsize;
	if(NoGrid<Ysize)
	{
		NoGrid=Ysize;
	}
	if(NoGrid<Zsize)
	{
		NoGrid=Zsize;
	}
	NoGrid=NoGrid*1.732/linespacing;
	int point=threadIdx.x+blockDim.x*blockIdx.x;
	//double spacing=sqrt(float(Xsize*Xsize+Ysize*Ysize+Zsize*Zsize))/NoGrid;
	while(point<NoGrid*NoGrid&&angle<NoAngles)
	{
		float xprime=(float(point/NoGrid)-0.5*(NoGrid-1))*linespacing;
		float yprime=(float(point-point/NoGrid*NoGrid)-0.5*(NoGrid-1))*linespacing;
		double k1,k2,k3;
		k1=k1_d[angle];
		k2=k2_d[angle];
		k3=k3_d[angle];
		float theta=acosf(k3);
		float phi=asinf(k2/__sinf(theta));
		if(k1/__sinf(theta)<0)
		{
			phi=-phi+PI;
		}
		float x=xprime*__cosf(theta)*__cosf(phi)-yprime*__sinf(phi);
		float y=xprime*__cosf(theta)*__sinf(phi)+yprime*__cosf(phi);
		float z=-xprime*__sinf(theta);

		//float k1=__sinf(theta)*__cosf(phi);
		//float k2=__sinf(theta)*__sinf(phi);
		//float k3=__cosf(theta);
		int iin,jin,kin,iout,jout,kout;
		cross2point(Xsize,Ysize,Zsize,&iin,&jin,&kin,x,y,z,k1,k2,k3,&iout,&jout,&kout);
		int nin,nout;
		if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize)
		{
			nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
			nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
			if(nin!=nout)
			{
				bodyIntegralInner(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn);				
			}

		}
		point+=blockDim.x*gridDim.x;
	}
}
__global__ void omni3dparallellinesESInner2(long Xsize,long Ysize,long Zsize,int NoAngles,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double*p,double*pn,int*pcountinner)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	long angle=threadIdx.y+blockDim.y*blockIdx.y;
	int NoGrid=128*2;
	int point=threadIdx.x+blockDim.x*blockIdx.x;
	float spacing=0.5;
	//double spacing=sqrt(float(Xsize*Xsize+Ysize*Ysize+Zsize*Zsize))/NoGrid;
	while(point<NoGrid*NoGrid&&angle<NoAngles)
	{
		float xprime=(float(point/NoGrid)-0.5*(NoGrid-1))*spacing;
		float yprime=(float(point-point/NoGrid*NoGrid)-0.5*(NoGrid-1))*spacing;
		double k1,k2,k3;
		k1=k1_d[angle];
		k2=k2_d[angle];
		k3=k3_d[angle];
		float theta=acosf(k3);
		float phi=asinf(k2/__sinf(theta));
		if(k1/__sinf(theta)<0)
		{
			phi=-phi+PI;
		}
		float x=xprime*__cosf(theta)*__cosf(phi)-yprime*__sinf(phi);
		float y=xprime*__cosf(theta)*__sinf(phi)+yprime*__cosf(phi);
		float z=-xprime*__sinf(theta);

		//float k1=__sinf(theta)*__cosf(phi);
		//float k2=__sinf(theta)*__sinf(phi);
		//float k3=__cosf(theta);
		int iin,jin,kin,iout,jout,kout;
		cross2point(Xsize,Ysize,Zsize,&iin,&jin,&kin,x,y,z,k1,k2,k3,&iout,&jout,&kout);
		int nin,nout;
		if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize)
		{
			nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
			nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
			int xin=floor(x+0.5);
			int yin=floor(y+0.5);
			int zin=floor(z+0.5);
			if(nin!=nout)
			{
				if(xin>=0&&xin<Xsize&&yin>=0&&yin<Ysize&&zin>=0&&zin<Zsize)
				{
					bodyIntegralInner2(Xsize,Ysize,Zsize,xin,yin,zin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn,pcountinner);
					bodyIntegralInner2(Xsize,Ysize,Zsize,iin,jin,kin,xin,yin,zin,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn,pcountinner);
				}
				else
				{
					bodyIntegralInner2(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn,pcountinner);
				}
			}

		}
		point+=blockDim.x*gridDim.x;
	}
}
__global__ void omni3dparallellinesInner(long Xsize,long Ysize,long Zsize,int NoAngles,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double*p,double*pn)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	long angle=threadIdx.y+blockDim.y*blockIdx.y;
	//for(int theta=0;theta<NoGrid;theta++)
	//{
	//for(int phi=0;phi<NoGrid;phi++)
	//{
	long nin=threadIdx.x+blockDim.x*blockIdx.x;
	while(nin<n&&angle<NoAngles)
	{

		//double k1=sinf(float(theta)/NoGrid*PI)*cosf(float(phi)/NoGrid*PI);
		//double k3=sinf(float(theta)/NoGrid*PI)*sinf(float(phi)/NoGrid*PI);
		//double k2=cosf(float(theta)/NoGrid*PI);
		double k1,k2,k3;
		k1=k1_d[angle];
		k2=k2_d[angle];
		k3=k3_d[angle];
		int iin,jin,kin;
		ntoijk(Xsize,Ysize,Zsize,nin,&iin,&jin,&kin);
		int iout,jout,kout;
		long nout=0;
		crosspoint(Xsize,Ysize,Zsize,iin,jin,kin,k1,k2,k3,&iout,&jout,&kout);
		if(iout+jout*Xsize+kout*Xsize*Ysize<Xsize*Ysize*Zsize&&iout+jout*Xsize+kout*Xsize*Ysize>=0)
		{
			nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
		}		
		if(nin!=nout)
		{
			bodyIntegralInner(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn);
		}		
		nin+=blockDim.x*gridDim.x;
		//angle+=blockDim.y*gridDim.y;
	}
}
__global__ void devidecountInner(long Xsize,long Ysize,long Zsize,double* p,double* pn,int* pcountinner)
{
	long tid=threadIdx.x+blockDim.x*blockIdx.x;
	while(tid<Xsize*Ysize*Zsize)
	{
		if(pcountinner[tid]>1)
		{
			p[tid]=pn[tid]/pcountinner[tid];
			pn[tid]=0;
		}

		tid+=blockDim.x*gridDim.x;
	}
}
__global__ void BCiterationvirtualgrid(long Xsize,long Ysize,long Zsize,int NoTheta,int NoBeta,long* index,long* ninvir,long *noutvir,double* pintvir,double*p,double *pn,int Noitr)

{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	//virtual boundary an ellipsoid
	int a=Xsize-1;
	int b=Ysize-1;
	int c=Zsize-1;
	float delttheta=PI/NoTheta;
	float deltbeta=2*PI/NoBeta;
	float xin,yin,zin,xout,yout,zout,k1,k2,k3,x,y,z;
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin,indexout;
	for(int iteration=0;iteration<Noitr;iteration++)
	{
		indexin=blockDim.x*blockIdx.x+threadIdx.x;
		indexout=blockDim.y*blockIdx.y+threadIdx.y;
		while(indexin<int(PI/delttheta)*int(PI/deltbeta)*2&&indexout<int(PI/delttheta)*int(PI/deltbeta)*2)
		{
			int nin,nout;
			nin=ninvir[indexin+indexout*NoTheta*NoBeta];
			nout=noutvir[indexin+indexout*NoTheta*NoBeta];
			long iout,jout,kout,iin,jin,kin;
			if(nout<=Xsize*Ysize-1)
			{
				kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			}
			if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
				iout=Xsize-2-iout;
				kout=kout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
				kout=Zsize-2-kout;
				jout=jout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
				kout=Zsize-2-kout;
				iout=iout+1;
			}
			if(nin<=Xsize*Ysize-1)
			{
				kin=0;jin=nin/Xsize;iin=nin-Xsize*jin;
			}
			if(nin>Xsize*Ysize-1&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iin=Xsize-1;jin=(nin-Xsize*Ysize)/(Zsize-1);kin=nin-Xsize*Ysize-jin*(Zsize-1)+1;
			}
			if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kin=Zsize-1;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-jin*(Xsize-1);iin=Xsize-2-iin;
			}
			if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jin=0;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kin*(Xsize-1);
				iin=Xsize-2-iin;
				kin=kin+1;
			}
			if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iin=0;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jin*(Zsize-2);
				kin=Zsize-2-kin;
				jin=jin+1;
			}
			if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jin=Ysize-1;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kin*(Xsize-2);
				kin=Zsize-2-kin;
				iin=iin+1;
			}
			int beta=0;
			if(pintvir[indexin+indexout*NoTheta*NoBeta]!=0)
			{
				pn[iout+jout*Xsize+kout*Xsize*Ysize]=(pn[iout+jout*Xsize+kout*Xsize*Ysize]+p[iin+jin*Xsize+kin*Xsize*Ysize]+pintvir[indexin+indexout*NoTheta*NoBeta])*0.5;
			}
			indexin=indexin+blockDim.x*gridDim.x;
			indexout=indexout+blockDim.y*gridDim.y;
		}
	}
	
	
}
void omni3virtualcpu(long Xsize,long Ysize,long Zsize,long *index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,long *pcount)
{
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	//virtual boundary an ellipsoid
	int a=Xsize-1;
	int b=Ysize-1;
	int c=Zsize-1;
	float delttheta=PI/16;
	float deltbeta=PI/16;
	float xin,yin,zin,xout,yout,zout,k1,k2,k3,x,y,z;
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	int iin,jin,kin,iout,jout,kout,indexin,indexout;
	CStdioFile log;
	log.Open("log.dat",CFile::modeCreate|CFile::modeWrite);
	for(float thetaout=0;thetaout<PI;thetaout+=delttheta)
	{
		for(float betaout=0;betaout<2*PI;betaout+=deltbeta)
		{
			for(float thetain=0;thetain<PI;thetain+=delttheta)
			{
				for(float betain=0;betain<PI;betain+=deltbeta)
				{
					xin=a*sin(thetain)*cos(betain);
					yin=b*sin(thetain)*sin(betain);
					zin=c*cos(thetain);
					xout=a*sin(thetaout)*cos(betaout);
					yout=b*sin(thetaout)*sin(betaout);
					zout=c*cos(thetaout);
					k1=xout-xin;
					k2=yout-yin;
					k3=zout-zin;
					iin=0;iout=0;jin=0;jout=0;kin=0;kout=0;
					if(!(k1==0&&k2==0&&k3==0))
					{
						/////case 1, vertical to x-axis
						if(k1==0&&k2!=0&&k3!=0)
						{
							if(xin>=-center_x&&xin<=center_x)
							{
								////four crossing point;y=0;y=max;z=0;z=max;
								double r=(-center_y-yin)/k2;double y1=-center_y;double z1=zin+k3*r;
								r=(center_y-yin)/k2;double y2=center_y;double z2=zin+k3*r;
								r=(-center_z-zin)/k3;double z3=-center_z;double y3=yin+k2*r;
								r=(center_z-zin)/k3;double z4=center_z;double y4=yin+k2*r;
								bool flag=0;
								if(z1<=center_z&&z1>=-center_z)//cross y=0;
								{
									if(flag==0)
									{
										iin=int(xin+center_x+0.5);
										jin=0;
										kin=int(z1+center_z+0.5);
									}
									if(flag==1)
									{
										iout=int(xin+center_x+0.5);
										jout=0;
										kout=int(z1+center_z+0.5);
									}
									flag=1;
								}
								if(z2<=center_z&&z2>=-center_z)//y=max;
								{
									if(flag==0)
									{
										iin=int(xin+center_x+0.5);
										jin=Ysize-1;
										kin=int(z2+center_z+0.5);
									}
									if(flag==1)
									{
										iout=int(xin+center_x+0.5);
										jout=Ysize-1;
										kout=int(z2+center_z+0.5);
									}
									flag=1;
								}
								if(y3<=center_y&&y3>=-center_y)//z=0;
								{
									if(flag==0)
									{
										iin=int(xin+center_x+0.5);
										jin=int(y3+center_y+0.5);
										kin=0;
									}
									if(flag==1)
									{
										iout=int(xin+center_x+0.5);
										jout=int(y3+center_y+0.5);
										kout=0;
									}
									flag=1;
								}
								if(y4<=center_y&&y4>=-center_y)
								{
									if(flag==0)
									{
										iin=int(xin+center_x+0.5);
										jin=int(y4+center_y+0.5);
										kin=Zsize-1;
									}
									if(flag==1)
									{
										iout=int(xin+center_x+0.5);
										jout=int(y4+center_y+0.5);
										kout=Zsize-1;
									}
								}
								//sorting intersection point by in, out order
								if(flag!=0)
								{
									if((jout-jin)*k2+(kout-kin)*k3<0)
									{
										int temp;
										temp=jin;jin=jout;jout=temp;
										temp=kin;kin=kout;kout=temp;
									}
								}
								
							}
						}
						///case 2, vertical to y-axis
						if(k1!=0&&k2==0&&k3!=0)
						{
							if(yin>=-center_y&&yin<=center_y)
							{
								////four crossing point
								double r=(-center_x-xin)/k1;double x1=-center_x;double z1=zin+k3*r;//x=0;
								r=(center_x-xin)/k1;double x2=center_x;double z2=zin+k3*r;//x=max
								r=(-center_z-zin)/k3;double z3=-center_z;double x3=xin+k1*r;//z=0;
								r=(center_z-zin)/k3;double z4=center_z;double x4=xin+k1*r;//z=max;
								bool flag=0;
								if(z1<=center_z&&z1>=-center_z)
								{
									if(flag==0)
									{
										iin=0;
										jin=int(yin+center_y+0.5);
										kin=int(z1+center_z+0.5);
									}
									if(flag==1)
									{
										iout=0;
										jout=int(yin+center_y+0.5);
										kout=int(z1+center_z+0.5);
									}
									flag=1;
								}
								if(z2<=center_z&&z2>=-center_z)
								{
									if(flag==0)
									{
										iin=Xsize-1;
										jin=int(yin+center_y+0.5);
										kin=int(z2+center_z+0.5);
									}
									if(flag==1)
									{
										iout=Xsize-1;
										jout=int(yin+center_y+0.5);
										kout=int(z2+center_z+0.5);
									}
									flag=1;
								}
								if(x3<=center_x&&x3>=-center_x)
								{
									if(flag==0)
									{
										iin=int(x3+center_x+0.5);
										jin=int(yin+center_y+0.5);
										kin=0;
									}
									if(flag==1)
									{
										iout=int(x3+center_x+0.5);
										jout=int(yin+center_y+0.5);
										kout=0;
									}
									flag=1;
								}
								if(x4<=center_x&&x4>=-center_x)
								{
									if(flag==0)
									{
										iin=int(x4+center_x+0.5);
										jin=int(yin+center_y+0.5);
										kin=Zsize-1;
									}
									if(flag==1)
									{
										iout=int(x4+center_x+0.5);
										jout=int(yin+center_y+0.5);
										kout=Zsize-1;
									}
									flag=1;
								}
								//sorting intersection point by in, out order
								if(flag!=0)
								{
									if((iout-iin)*k1+(kout-kin)*k3<0)
									{
										int temp;
										temp=iin;iin=iout;iout=temp;
										temp=kin;kin=kout;kout=temp;
									}
								}
								
							}
						}
						///case 3, vertical to z-axis
						if(k1!=0&&k2!=0&&k3==0)
						{
							if(zin>=-center_z&&zin<=center_z)
							{
								////four crossing point
								double r=(-center_x-xin)/k1;double x1=-center_x;double y1=yin+k2*r;//x=0;
								r=(center_x-xin)/k1;double x2=center_x;double y2=yin+k2*r;//x=max;
								r=(-center_y-zin)/k2;double y3=-center_y;double x3=xin+k1*r;//y=0;
								r=(center_y-zin)/k2;double y4=center_y;double x4=xin+k1*r;//y=max;
								bool flag=0;
								if(y1<=center_y&&y1>=-center_y)
								{
									if(flag==0)
									{
										iin=0;
										jin=int(y1+center_y+0.5);
										kin=int(zin+center_z+0.5);
									}
									if(flag==1)
									{
										iout=0;
										jout=int(y1+center_y+0.5);
										kout=int(zin+center_z+0.5);
									}
									flag=1;
								}
								if(y2<=center_y&&y2>=-center_y)
								{
									if(flag==0)
									{
										iin=Xsize-1;
										jin=int(y2+center_y+0.5);
										kin=int(zin+center_z+0.5);
									}
									if(flag==1)
									{
										iout=Xsize-1;
										jout=int(y2+center_y+0.5);
										kout=int(zin+center_z+0.5);
									}
									flag=1;
								}
								if(x3<=center_x&&x3>=-center_x)
								{
									if(flag==0)
									{
										iin=int(x3+center_x+0.5);
										jin=0;
										kin=int(zin+center_z+0.5);
									}
									if(flag==1)
									{
										iout=int(x3+center_x+0.5);
										jout=0;
										kout=int(zin+center_z+0.5);
									}
									flag=1;
								}
								if(x4<=center_x&&x4>=-center_x)
								{
									if(flag==0)
									{
										iin=int(x4+center_x+0.5);
										jin=Ysize-1;
										kin=int(zin+center_z+0.5);
									}
									if(flag==1)
									{
										iout=int(x4+center_x+0.5);
										jout=Ysize-1;
										kout=int(zin+center_z+0.5);
									}
									flag=1;
								}
								//sorting intersection point by in, out order
								if(flag!=0)
								{
									if((iout-iin)*k1+(jout-jin)*k2<0)
									{
										int temp;
										temp=iin;iin=iout;iout=temp;
										temp=jin;jin=jout;jout=temp;
									}
								}
								
							}
						}
						///case 4, vertical to plane IJ
						if(abs(k1)<zero&&abs(k2)<zero&&abs(k3)>=zero)
						{

							if(xin<=center_x&&xin>=-center_x&&yin<=center_y&&yin>=-center_y)
							{
								iin=int(xin+center_x+0.5);iout=iin;
								jin=int(yin+center_y+0.5);jout=jin;
								if(k3>0)
								{
									kin=0;kout=Zsize-1;
								}
								else{
									kin=Zsize-1;kout=0;
								}

							}
						}
						///case 5, vertical to IK plane
						if(abs(k1)<zero&&abs(k2)>=zero&&abs(k3)<zero)
						{
							if(xin>=-center_x&&xin<=center_x&&zin>=-center_z&&zin<=center_z)
							{
								iin=int(xin+center_x+0.5);iout=iin;
								kin=int(zin+center_z+0.5);kout=kin;
								if(k2>0)
								{
									jout=Ysize-1;jin=0;
								}
								else
								{
									jin=Ysize-1;jout=0;
								}

							}
						}
						///case 6, vertical to JK plane
						if(abs(k1)>=zero&&abs(k2)<zero&&abs(k3)<zero)
						{
							if(yin>=-center_y&&yin<center_y&&zin>=-center_z&&zin<=center_z)
							{
								jin=int(yin+center_y+0.5);jout=jin;
								kin=int(zin+center_z+0.5);kout=kin;
								if(k1>0)
								{
									iout=Xsize-1;iin=0;
								}
								else
								{
									iin=Xsize-1;iout=0;
								}
							}
							
						}
						/// case 7, purely inclined
						if(abs(k1)>=zero&&abs(k2)>=zero&&abs(k3)>=zero)
						{
							/// six crossing point
							double r;
							double x1,x2,x3,x4,x5,x6;
							double y1,y2,y3,y4,y5,y6;
							double z1,z2,z3,z4,z5,z6;
							r=(-center_x-xin)/k1;x1=-center_x;y1=yin+k2*r;z1=zin+k3*r;//x=0
							r=(center_x-xin)/k1;x2=center_x;y2=yin+k2*r;z2=zin+k3*r;//x=max
							r=(-center_y-yin)/k2;x3=xin+k1*r;y3=-center_y;z3=zin+k3*r;//y=0;
							r=(center_y-yin)/k2;x4=xin+k1*r;y4=center_y;z4=zin+k3*r;//y=max
							r=(-center_z-zin)/k3;x5=xin+k1*r;y5=yin+k2*r;z5=-center_z;//z=0;
							r=(center_z-zin)/k3;x6=xin+k1*r;y6=yin+k2*r;z6=center_z;//z=max
							bool flag=0;
							if(y1<=center_y&&y1>=-center_y&&z1<=center_z&&z1>=-center_z)
							{
								if(flag==0)
								{
									iin=0;
									jin=int(y1+center_y+0.5);
									kin=int(z1+center_z+0.5);
								}
								if(flag==1)
								{
									iout=0;
									jout=int(y1+center_y+0.5);
									kout=int(z1+center_z+0.5);
								}
								flag=1;
							}
							if(y2<=center_y&&y2>=-center_y&&z2<=center_z&&z2>=-center_z)
							{
								if(flag==0)
								{
									iin=Xsize-1;
									jin=int(y2+center_y+0.5);
									kin=int(z2+center_z+0.5);
								}
								if(flag==1)
								{
									iout=Xsize-1;
									jout=int(y2+center_y+0.5);
									kout=int(z2+center_z+0.5);
								}
								flag=1;
							}
							if(x3<=center_x&&x3>=-center_x&&z3<=center_z&&z3>=-center_z)
							{
								if(flag==0)
								{
									iin=int(x3+center_x+0.5);
									jin=0;
									kin=int(z3+center_z+0.5);
								}
								if(flag==1)
								{
									iout=int(x3+center_x+0.5);
									jout=0;
									kout=int(z3+center_z+0.5);
								}
								flag=1;
							}
							if(x4<=center_x&&x4>=-center_x&&z4<=center_z&&z4>=-center_z)
							{
								if(flag==0)
								{
									iin=int(x4+center_x+0.5);
									jin=Ysize-1;
									kin=int(z4+center_z+0.5);
								}
								if(flag==1)
								{
									iout=int(x4+center_x+0.5);
									jout=Ysize-1;
									kout=int(z4+center_z+0.5);
								}
								flag=1;
							}
							if(x5<=center_x&&x5>=-center_x&&y5<=center_y&&y5>=-center_y)
							{
								if(flag==0)
								{
									iin=int(x5+center_x+0.5);
									jin=int(y5+center_y+0.5);
									kin=0;
								}
								if(flag==1)
								{
									iout=int(x5+center_x+0.5);
									jout=int(y5+center_y+0.5);
									kout=0;
								}
								flag=1;
							}
							if(x6<=center_x&&x6>=-center_x&&y6<=center_y&&y6>=-center_y)
							{
								if(flag==0)
								{
									iin=int(x6+center_x+0.5);
									jin=int(y6+center_y+0.5);
									kin=Zsize-1;
								}
								if(flag==1)
								{
									iout=int(x6+center_x+0.5);
									jout=int(y6+center_y+0.5);
									kout=Zsize-1;
								}
								flag=1;
							}
							//sorting intersection point by in, out order
							if(flag!=0)
							{
								if((iout-iin)*k1+(jout-jin)*k2+(kout-kin)*k3<0)
								{
									int temp;
									temp=iin;iin=temp;iout=temp;
									temp=jin;jin=jout;jout=temp;
									temp=kin;kin=kout;kout=temp;
								}
							}
							
						}
						//////////////////////////////END OF CALCULATING IN AND OUT POINT ON REAL BOUNDARY////////////////////////////////
						if((iin-center_x-xin)*(iin-center_x-xout)+(jin-center_y-yin)*(jin-center_y-yout)+(kin-center_z-zin)*(kin-center_z-zout)<0&&(iin+jin+kin+iout+jout+kout)!=0&&!(iin==iout&&jin==jout&&kin==kout))
						{
							int nin,nout;
							long ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
							ilast=iin;jlast=jin;klast=kin;					    
							do 
							{
								if(ilast<iout)
								{
									inext1=ilast+1;jnext1=jlast;knext1=klast;
								}
								if(ilast==iout)
								{
									inext1=ilast-1e6;jnext1=jlast;knext1=klast;
								}
								if(ilast>iout)
								{
									inext1=ilast-1;jnext1=jlast;knext1=klast;
								}
								if(jlast<jout)
								{
									inext2=ilast;jnext2=jlast+1;knext2=klast;
								}
								if(jlast==jout)
								{
									inext2=ilast;jnext2=jlast-1e6;knext2=klast;
								}
								if(jlast>jout)
								{
									inext2=ilast;jnext2=jlast-1;knext2=klast;
								}
								if(klast<kout)
								{
									inext3=ilast;jnext3=jlast;knext3=klast+1;
								}
								if(klast==kout)
								{
									inext3=ilast;jnext3=jlast;knext3=klast-1e6;
								}
								if(klast>kout)
								{
									inext3=ilast;jnext3=jlast;knext3=klast-1;
								}
								///determine which one is closer to longegration path
								double r,d1,d2,d3;
								r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
								x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
								d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
								r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
								x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
								d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
								r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
								x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
								d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
								//////End of calculation distance///////////////
								nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
								nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
								/*if(kin==0)
								{
									nin=iin+jin*Xsize;
								}
								if(iin==Xsize-1&&kin!=0)
								{
									nin=Xsize*Ysize-1+kin+(Ysize-1-jin)*(Zsize-1);
								}
								if(kin==Zsize-1&&iin!=Xsize-1)
								{
									nin=Xsize*Ysize-1+(Zsize-1)*Ysize+Xsize-1-iin+jin*(Xsize-1);
								}
								if(jin==0&&iin!=Xsize-1&&kin!=0&&kin!=Zsize-1)
								{
									nin=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+Xsize-1-iin+(kin-1)*(Xsize-1);//????
								}
								if(iin==0&&jin!=0&&kin!=0&&kin!=Zsize-1)
								{
									nin=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+(Xsize-1)*(Zsize-2)+Zsize-1-kin+(jin-1)*(Zsize-2);
								}
								if(jin==Ysize-1&&iin!=0&&iin!=Xsize-1&&kin!=0&&kin!=Zsize-1)
								{
									nin=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2)+iin+(kin-1)*(Xsize-2);
								}
								if(kout==0)
								{
									nout=iout+jout*Xsize;
								}
								if(iout==Xsize-1&&kout!=0)
								{
									nout=Xsize*Ysize-1+kout+(Ysize-1-jout)*(Zsize-1);
								}
								if(kout==Zsize-1&&iout!=Xsize-1)
								{
									nout=Xsize*Ysize-1+(Zsize-1)*Ysize+Xsize-1-iout+jout*(Xsize-1);
								}
								if(jout==0&&iout!=Xsize-1&&kout!=0&&kout!=Zsize-1)
								{
									nout=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+Xsize-1-iout+(kout-1)*(Xsize-1);
								}
								if(iout==0&&jout!=0&&kout!=0&&kout!=Zsize-1)
								{
									nout=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+(Xsize-1)*(Zsize-2)+Zsize-1-kout+(jout-1)*(Zsize-2);
								}
								if(jout==Ysize-1&&iout!=0&&iout!=Xsize-1&&kout!=0&&kout!=Zsize-1)
								{
									nout=Xsize*Ysize-1+(Zsize-1)*Ysize+Ysize*(Xsize-1)+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2)+iout+(kout-1)*(Xsize-2);
								}*/
								if(d1<=d2&&d1<=d3)
								{
									pint[nin+nout*n]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
									
									ilast=inext1;

								}
								if(d2<d1&&d2<=d3)
								{
									pint[nin+nout*n]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
									
									jlast=jnext2;
								}
								if(d3<d1&&d3<d2)
								{
									pint[nin+nout*n]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
									
									klast=knext3;
								}
							} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-5);
							pcount[nin+nout*n]++;
							CString str;
							str.Format(_T("%04d--%04d  (%02d,%02d,%02d) (%02d,%02d,%02d) %10.8f %02d\n"),nin,nout,iin,jin,kin,iout,jout,kout,pint[nin+nout*n],pcount[nin+nout*n]);
							cout<<str;
							log.WriteString(str);
						}
						
					}
					
				}
			}
		}
	}
	int no=0;
	for(int k=0;k<n*n;k++)
	{
		if(pcount[k]>0)
		{
			pint[k]=pint[k]/pcount[k];
			no++;
		}
	}
	cout<<no<<endl;
	log.Close();
}
double BCIterationCPU(long Xsize,long Ysize,long Zsize,double* pint,double *p,double* pn,double eps,int Noitr)
{
	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	double pdiffold=0;
	double pdiffnew=0;
	double pdiffrela=100;
	double meanp=0;
	long iteration=0;
	while(iteration<Noitr&&pdiffrela>eps)
	{
		meanp=0;
		for(long nout=n-1;nout>=0;nout--)
		{
			long iout,jout,kout;
			if(nout<=Xsize*Ysize-1)
			{
				kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			}
			if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
				iout=Xsize-2-iout;
				kout=kout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
				kout=Zsize-2-kout;
				jout=jout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
				kout=Zsize-2-kout;
				iout=iout+1;
			}
			long beta=0;
			for(long nin=0;nin<n;nin++)
			{
				long iin,jin,kin;

				if(nin<=Xsize*Ysize-1)
				{
					kin=0;jin=nin/Xsize;iin=nin-Xsize*jin;
				}
				if(nin>Xsize*Ysize-1&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1))
				{
					iin=Xsize-1;jin=(nin-Xsize*Ysize)/(Zsize-1);kin=nin-Xsize*Ysize-jin*(Zsize-1)+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
				{
					kin=Zsize-1;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-jin*(Xsize-1);iin=Xsize-2-iin;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
				{
					jin=0;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
					iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kin*(Xsize-1);
					iin=Xsize-2-iin;
					kin=kin+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
				{
					iin=0;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
					kin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jin*(Zsize-2);
					kin=Zsize-2-kin;
					jin=jin+1;
				}
				if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
				{
					jin=Ysize-1;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
					iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kin*(Xsize-2);
					kin=Zsize-2-kin;
					iin=iin+1;
				}
				///////////
				if(pint[nin+nout*n]!=0)
				{
					pn[iout+jout*Xsize+kout*Xsize*Ysize]+=p[iin+jin*Xsize+kin*Xsize*Ysize]+pint[nin+nout*n];
					beta++;
				}

			}
			pn[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize]/(beta+1);
			p[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize];
			//cout<<pn[iout+jout*Xsize+kout*Xsize*Ysize]<<endl;
		}
		iteration++;
		for(long nout=0;nout<n;nout++)
		{
			long iout,jout,kout;
			if(nout<=Xsize*Ysize-1)
			{
				kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
			}
			if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
			{
				iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
			{
				kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
			{
				jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
				iout=Xsize-2-iout;
				kout=kout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
				kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
				kout=Zsize-2-kout;
				jout=jout+1;
			}
			if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
			{
				jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
				iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
				kout=Zsize-2-kout;
				iout=iout+1;
			}
			meanp+=pn[iout+jout*Xsize+kout*Xsize*Ysize];
			pdiffnew+=abs(p[iout+jout*Xsize+kout*Xsize*Ysize]-pn[iout+jout*Xsize+kout*Xsize*Ysize]);
			p[iout+jout*Xsize+kout*Xsize*Ysize]=pn[iout+jout*Xsize+kout*Xsize*Ysize];
			//pn[iout+jout*Xsize+kout*Xsize*Ysize]=0;
			
		}
		meanp=meanp/n;
		pdiffnew=pdiffnew/n;
		pdiffrela=abs(pdiffnew-pdiffold);
		pdiffold=pdiffnew;pdiffnew=0;
	}
	return meanp;
}
void omni3Dinner(long Xsize,long Ysize,long Zsize,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,long *pcount,double *p,double* pn,int itrNo)
{
	int iteration=0;
	double rms=0;
	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	while(iteration<itrNo)
	{
			for(int nin=0;nin<n;nin=nin+1)
			{
				for(int nout=0;nout<n;nout=nout+1)
				{
					int iout,jout,kout;
					int facein,faceout;
					if(nout<=Xsize*Ysize-1)
					{
						kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
						faceout=1;
					}
					if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
					{
						iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
						faceout=2;
					}
					if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
					{
						kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
						faceout=3;
					}
					if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
					{
						jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
						iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
						iout=Xsize-2-iout;
						kout=kout+1;
						faceout=4;
					}
					if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
					{
						iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
						kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
						kout=Zsize-2-kout;
						jout=jout+1;
						faceout=5;
					}
					if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
					{
						jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
						iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
						kout=Zsize-2-kout;
						iout=iout+1;
						faceout=6;
					}
					int iin,jin,kin;

					if(nin<=Xsize*Ysize-1)
					{
						kin=0;jin=nin/Xsize;iin=nin-Xsize*jin;
						facein=1;
					}
					if(nin>Xsize*Ysize-1&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1))
					{
						iin=Xsize-1;jin=(nin-Xsize*Ysize)/(Zsize-1);kin=nin-Xsize*Ysize-jin*(Zsize-1)+1;
						facein=2;
					}
					if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
					{
						kin=Zsize-1;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-jin*(Xsize-1);iin=Xsize-2-iin;
						facein=3;
					}
					if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
					{
						jin=0;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
						iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kin*(Xsize-1);
						iin=Xsize-2-iin;
						kin=kin+1;
						facein=4;
					}
					if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nin<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
					{
						iin=0;jin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
						kin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jin*(Zsize-2);
						kin=Zsize-2-kin;
						jin=jin+1;
						facein=5;
					}
					if(nin>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
					{
						jin=Ysize-1;kin=(nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
						iin=nin-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kin*(Xsize-2);
						kin=Zsize-2-kin;
						iin=iin+1;
						facein=6;
					}
					int ilast,jlast,klast,inext1,inext2,inext3,jnext1,jnext2,jnext3,knext1,knext2,knext3;
					ilast=iin;jlast=jin;klast=kin;					    
					if(nin!=nout&&nin>=0&&nin<n&&nout>=0&&nout<n)
					{
						double k1=iout-iin;
						double k2=jout-jin;
						double k3=kout-kin;
						double l=sqrt(k1*k1+k2*k2+k3*k3);
						k1=k1/l;
						k2=k2/l;
						k3=k3/l;
						//cout<<"indexin: "<<nin<<" indexout:"<<nout<<endl;
						//cout<<'('<<iin<<','<<jin<<','<<kin<<")  "<<'('<<iout<<','<<jout<<','<<kout<<")  "<<endl;
						//log<<"indexin: "<<nin<<" indexout:"<<nout<<endl;
						//log<<'('<<iin<<','<<jin<<','<<kin<<")  "<<'('<<iout<<','<<jout<<','<<kout<<")  "<<endl;
						do 
						{
							if(ilast<iout)
							{
								inext1=ilast+1;jnext1=jlast;knext1=klast;
							}
							if(ilast==iout)
							{
								inext1=ilast-1e6;jnext1=jlast;knext1=klast;
							}
							if(ilast>iout)
							{
								inext1=ilast-1;jnext1=jlast;knext1=klast;
							}
							if(jlast<jout)
							{
								inext2=ilast;jnext2=jlast+1;knext2=klast;
							}
							if(jlast==jout)
							{
								inext2=ilast;jnext2=jlast-1e6;knext2=klast;
							}
							if(jlast>jout)
							{
								inext2=ilast;jnext2=jlast-1;knext2=klast;
							}
							if(klast<kout)
							{
								inext3=ilast;jnext3=jlast;knext3=klast+1;
							}
							if(klast==kout)
							{
								inext3=ilast;jnext3=jlast;knext3=klast-1e6;
							}
							if(klast>kout)
							{
								inext3=ilast;jnext3=jlast;knext3=klast-1;
							}
							///determine which one is closer to integration path
							double r,d1,d2,d3,x,y,z;
							r=k1*inext1-iin*k1+k2*jnext1-k2*jin+k3*knext1-k3*kin;
							x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
							d1=sqrt((x-inext1)*(x-inext1)+(y-jnext1)*(y-jnext1)+(z-knext1)*(z-knext1));
							r=k1*inext2-iin*k1+k2*jnext2-k2*jin+k3*knext2-k3*kin;
							x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
							d2=sqrt((x-inext2)*(x-inext2)+(y-jnext2)*(y-jnext2)+(z-knext2)*(z-knext2));
							r=k1*inext3-iin*k1+k2*jnext3-k2*jin+k3*knext3-k3*kin;
							x=iin+k1*r;y=jin+k2*r;z=kin+k3*r;
							d3=sqrt((x-inext3)*(x-inext3)+(y-jnext3)*(y-jnext3)+(z-knext3)*(z-knext3));
							//////End of calculation distance///////////////
							//path 1
							if(d1<=d2&&d1<=d3)
							{
								pn[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+=p[ilast+jlast*Xsize+klast*Xsize*Ysize]-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								pcount[inext1+jnext1*Xsize+knext1*Xsize*Ysize]++;
								//pint[nin+nout*n]+=-density*(inext1-ilast)*deltx*0.5*(DuDt[inext1+jnext1*Xsize+knext1*Xsize*Ysize]+DuDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								ilast=inext1;

							}
							if(d2<d1&&d2<=d3)
							{
								pn[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+=p[ilast+jlast*Xsize+klast*Xsize*Ysize]-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								pcount[inext2+jnext2*Xsize+knext2*Xsize*Ysize]++;
								//pint[nin+nout*n]+=-density*(jnext2-jlast)*delty*0.5*(DvDt[inext2+jnext2*Xsize+knext2*Xsize*Ysize]+DvDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								
								jlast=jnext2;
							}
							if(d3<d1&&d3<d2)
							{
								pn[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+=p[ilast+jlast*Xsize+klast*Xsize*Ysize]-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								pcount[inext3+jnext3*Xsize+knext3*Xsize*Ysize]++;
								//pint[nin+nout*n]+=-density*(knext3-klast)*deltz*0.5*(DwDt[inext3+jnext3*Xsize+knext3*Xsize*Ysize]+DwDt[ilast+jlast*Xsize+klast*Xsize*Ysize]);
								klast=knext3;
							}
						} while (abs(ilast-iout)+abs(jlast-jout)+abs(klast-kout)>1e-3);
						
						
					}

					//cout<<thetain<<' '<<betain<<endl;
					//cout<<thetaout<<' '<<betaout<<endl;
					//cout<<"k1="<<k1<<" k2="<<k2<<" k3="<<k3<<endl;
					//cout<<indexin<<" "<<indexout<<endl;
				}
			}
			rms=0;
			for(int k=0;k<Xsize*Ysize*Zsize;k++)
			{
				pn[k]=pn[k]/pcount[k];
				pcount[k]=0;
				rms+=(p[k]-pn[k])*(p[k]-pn[k]);
			}
			rms=sqrt(rms/Xsize/Ysize/Zsize);
			cout<<"Iteration: "<<iteration<<" rms:  "<<rms<<endl;
			memcpy(p,pn,sizeof(double)*Xsize*Ysize*Zsize);
			memset(pn,0,sizeof(double)*Xsize*Ysize*Zsize);
			iteration++;
	}
			
}
void calIndex(long*index,long Xsize,long Ysize,long Zsize)
{
	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	for(long nout=n-1;nout>=0;nout--)
	{
		long iout,jout,kout;
		if(nout<=Xsize*Ysize-1)
		{
			kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
		}
		if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
		{
			iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
		{
			kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
		{
			jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
			iout=Xsize-2-iout;
			kout=kout+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
			kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
			kout=Zsize-2-kout;
			jout=jout+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
			kout=Zsize-2-kout;
			iout=iout+1;
		}
		index[iout+jout*Xsize+kout*Xsize*Ysize]=nout;
	}
}
void omni3dparallellinescpu(long Xsize,long Ysize,long Zsize,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	//long angle=threadIdx.y+blockDim.y*blockIdx.y;
	int NoGrid=20;
	CStdioFile log;
	log.Open("log.dat",CFile::modeCreate|CFile::modeWrite);
	for(int phi=0;phi<NoGrid;phi++)
	{
    int i=0;
	for(int theta=0;theta<NoGrid;theta++)
	{
	long nin=0;
	while(nin<n)
	{
		double k1=sinf(float(theta)/NoGrid*PI)*cosf(float(phi)/NoGrid*PI);
		double k2=sinf(float(theta)/NoGrid*PI)*sinf(float(phi)/NoGrid*PI);
		double k3=cosf(float(theta)/NoGrid*PI);
		int iin,jin,kin;
		ntoijk(Xsize,Ysize,Zsize,nin,&iin,&jin,&kin);
		int iout,jout,kout;	
		crosspoint(Xsize,Ysize,Zsize,iin,jin,kin,k1,k2,k3,&iout,&jout,&kout);
		
		long nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
		if(nin!=nout)
		{
			pint[nin+nout*n]+=bodyIntegral(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,pcount);
			pcount[nin+nout*n]++;
		}	
		CString str;
		str.Format(_T("%6.5f %6.5f %6.5f %05d %05d (%02d,%02d,%02d) (%02d,%02d,%02d) %13.10f\n"),k1,k2,k3,nin,nout,iin,jin,kin,iout,jout,kout,pint[nin+nout*n]);
		log.WriteString(str);
		//cout<<str;
		nin++;
		
	}
	}
	}
	log.Close();
	//__syncthreads();
}
void omni3dparallellinesEqualSpacingCPU(long Xsize,long Ysize,long Zsize,int NoAngles,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double* pint,int* pcount,int* pcountinner)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;	
	int NoGrid=16;
	float spacing=1;
	//CStdioFile log;
	//log.Open("log.dat",CFile::modeCreate|CFile::modeWrite);
	//double spacing=sqrt(float(Xsize*Xsize+Ysize*Ysize+Zsize*Zsize))/NoGrid;
	for(int angle=0;angle<NoAngles;angle++)
	{
		
		for(int point=0;point<NoGrid*NoGrid;point++)
		{
			float xprime=(float(point/NoGrid)-0.5*NoGrid)*spacing;
			float yprime=(float(point-point/NoGrid*NoGrid)-0.5*NoGrid)*spacing;
			double k1,k2,k3;
			k1=k1_d[angle];
			k2=k2_d[angle];
			k3=k3_d[angle];
			float theta=acosf(k3);
			float phi=asinf(k2/sinf(theta));
			if(k1/sinf(theta)<0)
			{
				phi=-phi+PI;
			}
			float x=xprime*cosf(theta)*cosf(phi)-yprime*sinf(phi);
			float y=xprime*cosf(theta)*sinf(phi)+yprime*cosf(phi);
			float z=-xprime*sinf(theta);
			//float k1=sinf(theta)*cosf(phi);
			//float k2=sinf(theta)*sinf(phi);
			//float k3=cosf(theta);
			int iin,jin,kin,iout,jout,kout;
			cross2point(Xsize,Ysize,Zsize,&iin,&jin,&kin,x,y,z,k1,k2,k3,&iout,&jout,&kout);
			int nin,nout;
			if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize)
			{
				nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
				nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
				if(nin!=nout)
				{
					pint[nin+nout*n]+=bodyIntegral(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,pcountinner);
					pcount[nin+nout*n]++;
				}
				//CString str;
				//str.Format(_T("%6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %6.4f %02d %02d %02d %02d %02d %02d\n"),theta,phi,k1,k2,k3,x,y,z,iin,jin,kin,iout,jout,kout);
				//if(angle==10000/2-1)
				//{
				//	log.WriteString(str);
				//}
				
			}
		}
	}
	//log.Close();
}
void omni3dparallellinesESInnerCPU(long Xsize,long Ysize,long Zsize,int NoAngles,float linespacing,double* k1_d,double* k2_d,double* k3_d,long*index,double deltx,double delty,double deltz,double density,double* DuDt,double *DvDt,double *DwDt,double*p,double*pn)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	float center_x=(Xsize-1)/2.0;
	float center_y=(Ysize-1)/2.0;
	float center_z=(Zsize-1)/2.0;
	int NoGrid=Xsize;
	if(NoGrid<Ysize)
	{
		NoGrid=Ysize;
	}
	if(NoGrid<Zsize)
	{
		NoGrid=Zsize;
	}
	NoGrid=NoGrid*1.732;
	//double spacing=sqrt(float(Xsize*Xsize+Ysize*Ysize+Zsize*Zsize))/NoGrid;
	for(int angle=0;angle<NoAngles;angle++)
	{
		for(int point=0;point<NoGrid*NoGrid;point++)
		{
			float xprime=(float(point/NoGrid)-0.5*(NoGrid-1))*linespacing;
			float yprime=(float(point-point/NoGrid*NoGrid)-0.5*(NoGrid-1))*linespacing;
			double k1,k2,k3;
			k1=k1_d[angle];
			k2=k2_d[angle];
			k3=k3_d[angle];
			float theta=acosf(k3);
			float phi=asinf(k2/sinf(theta));
			if(k1/sinf(theta)<0)
			{
				phi=-phi+PI;
			}
			float x=xprime*cosf(theta)*cosf(phi)-yprime*sinf(phi);
			float y=xprime*cosf(theta)*sinf(phi)+yprime*cosf(phi);
			float z=-xprime*sinf(theta);

			//float k1=__sinf(theta)*__cosf(phi);
			//float k2=__sinf(theta)*__sinf(phi);
			//float k3=__cosf(theta);
			int iin,jin,kin,iout,jout,kout;
			cross2point(Xsize,Ysize,Zsize,&iin,&jin,&kin,x,y,z,k1,k2,k3,&iout,&jout,&kout);
			int nin,nout;
			if(iin>=0&&iin<Xsize&&jin>=0&&jin<Ysize&&kin>=0&&kin<Zsize&&iout>=0&&iout<Xsize&&jout>=0&&jout<Ysize&&kout>=0&&kout<Zsize)
			{
				nin=index[iin+jin*Xsize+kin*Xsize*Ysize];
				nout=index[iout+jout*Xsize+kout*Xsize*Ysize];
				if(nin!=nout)
				{
					bodyIntegralInner(Xsize,Ysize,Zsize,iin,jin,kin,iout,jout,kout,k1,k2,k3,deltx,delty,deltz,density,DuDt,DvDt,DwDt,p,pn);				
				}

			}
		}
	}
	
}
void devidecountCPU(long Xsize,long Ysize,long Zsize,double* pint,int* pcount)
{
	int n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	for(int tid=0;tid<n*n;tid++)
	{
		if(pcount[tid]>1)
		{
			pint[tid]/=pcount[tid];
		}

	}
}
void devidecountInnerCPU(long Xsize,long Ysize,long Zsize,double* p,double* pn,int* pcountinner)
{
	
	for(int tid=0;tid<Xsize*Ysize*Zsize;tid++)
	{
		if(pcountinner[tid]>1)
		{
			p[tid]=pn[tid]/pcountinner[tid];
			pn[tid]=0;
		}
	}
}
void randOnSphere(int NoRand,double* k1,double* k2,double* k3)
{
	//curandGenerator_t gen;
	//curandCreateGenerator(&gen,CURAND_RNG_PSEUDO_DEFAULT);
	//curandSetPseudoRandomGeneratorSeed(gen, 1234ULL);

}
__global__ void calIndexGPU(long*index,long Xsize,long Ysize,long Zsize)
{
	long nout=threadIdx.x+blockIdx.x*blockDim.x;
	long n=Xsize*Ysize*2+(Ysize-2)*Zsize*2+(Xsize-2)*(Zsize-2)*2;
	while(nout<n)
	{
		long iout,jout,kout;
		if(nout<=Xsize*Ysize-1)
		{
			kout=0;jout=nout/Xsize;iout=nout-Xsize*jout;
		}
		if(nout>Xsize*Ysize-1&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1))
		{
			iout=Xsize-1;jout=(nout-Xsize*Ysize)/(Zsize-1);kout=nout-Xsize*Ysize-jout*(Zsize-1)+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize)
		{
			kout=Zsize-1;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1))/(Xsize-1);iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-jout*(Xsize-1);iout=Xsize-2-iout;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2))
		{
			jout=0;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize)/(Xsize-1);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-kout*(Xsize-1);
			iout=Xsize-2-iout;
			kout=kout+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)&&nout<=Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			iout=0;jout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2))/(Zsize-2);
			kout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-jout*(Zsize-2);
			kout=Zsize-2-kout;
			jout=jout+1;
		}
		if(nout>Xsize*Ysize-1+Ysize*(Zsize-1)+(Xsize-1)*Ysize+(Xsize-1)*(Zsize-2)+(Ysize-1)*(Zsize-2))
		{
			jout=Ysize-1;kout=(nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2))/(Xsize-2);
			iout=nout-Xsize*Ysize-Ysize*(Zsize-1)-(Xsize-1)*Ysize-(Xsize-1)*(Zsize-2)-(Ysize-1)*(Zsize-2)-kout*(Xsize-2);
			kout=Zsize-2-kout;
			iout=iout+1;
		}
		index[iout+jout*Xsize+kout*Xsize*Ysize]=nout;
		nout+=blockDim.x*gridDim.x;
	}

}
///////////////////////////For DNS Verification Version/////////////////////////////////

int main()
{
	cudaDeviceProp prop;
	long DeviceNo=0;
	cudaSetDevice(DeviceNo);
	cudaGetDeviceProperties( &prop, DeviceNo ) ;
	printf( " ----------- General Information for device %d --------\n", DeviceNo );
	printf( "Name: %s\n", prop.name );
	printf( "Compute capability: %d.%d\n", prop.major, prop.minor );
	printf( "Clock rate: %d\n", prop.clockRate );
	printf( "Device copy overlap: " );
	if (prop.deviceOverlap)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( "Kernel execition timeout : " );
	if (prop.kernelExecTimeoutEnabled)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( " ------------ Memory Information for device %d ---------\n", DeviceNo );
	printf( "Total global mem: %ld\n", prop.totalGlobalMem );
	printf( "Total constant Mem: %ld\n", prop.totalConstMem );
	printf( "Max mem pitch: %ld\n", prop.memPitch );
	printf( "Texture Alignment: %ld\n", prop.textureAlignment );
	printf( " --- MP Information for device %d ---\n", DeviceNo );
	printf( "Multiprocessor count: %d\n",
		prop.multiProcessorCount );
	printf( "Shared mem per mp: %ld\n", prop.sharedMemPerBlock );
	printf( "Registers per mp: %d\n", prop.regsPerBlock );
	printf( "Threads in warp: %d\n", prop.warpSize );
	printf( "Max threads per block: %d\n",
		prop.maxThreadsPerBlock );
	printf( "Max thread dimensions: (%d, %d, %d)\n",
		prop.maxThreadsDim[0], prop.maxThreadsDim[1],
		prop.maxThreadsDim[2] );
	printf( "Max grid dimensions: (%d, %d, %d)\n",
		prop.maxGridSize[0], prop.maxGridSize[1],
		prop.maxGridSize[2] );
	printf( "\n" );
	long Imax,Jmax,Kmax,n,PlaneSt,Planedt,PlaneEnd,FileNumSt,FileNumDelt,FileNumEnd;
	cudaEvent_t start, stop;
	float time;
	clock_t st,time1,time2;
	st=clock();
	double rho,scale;
	double density=1;
	double eps=1e-10;
	double meanpcal=0;
	double meanpdns=0;
	double* x,*y,*z,*u,*v,*w,*dudt,*dvdt,*dwdt,*pint,*p,*pn,*pdns,*RHS;
	double* k1,*k2,*k3;
	double* dudt_d,*dvdt_d,*dwdt_d,*pint_d,*p_d,*pn_d,linespacing;
	double* k1_d,*k2_d,*k3_d;
	long *index,*index_d;
	int *pcountinner,*pcountinner_d;
	int* pcount_d,*pcountitr_d,*pcount;
	int NoAngles=10000;
	int NoItr=20;
	CString FileAcc=_T("Force.dat");
	CString FileSphereGrid=_T("radomnumber.dat");
	CString FilePdns=_T("P64.dat");
	CString FileOut=_T("Pressure.dat");
	CString FileLog=_T("Log.dat");
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start, 0);
	
	Imax=64;
	Jmax=64;
	Kmax=64;
	double deltx=0.006135923151543;
	double delty=0.006135923151543;
	double deltz=0.006135923151543;
	linespacing=1;
	n=Imax*Jmax*2+(Jmax-2)*Kmax*2+(Imax-2)*(Kmax-2)*2;
	x=new double[Imax*Jmax*Kmax];
	y=new double[Imax*Jmax*Kmax];
	z=new double[Imax*Jmax*Kmax];
	u=new double[Imax*Jmax*Kmax];
	v=new double[Imax*Jmax*Kmax];
	w=new double[Imax*Jmax*Kmax];
	dudt=new double[Imax*Jmax*Kmax];
	dvdt=new double[Imax*Jmax*Kmax];
	dwdt=new double[Imax*Jmax*Kmax];
	p=new double[Imax*Jmax*Kmax];
	pn=new double[Imax*Jmax*Kmax];
	pdns=new double[Imax*Jmax*Kmax];
	RHS=new double[Imax*Jmax*Kmax];
	pint=new double[n*n];
	pcountinner=new int[Imax*Jmax*Kmax];
	pcount=new int[n*n];
	index=new long[Imax*Jmax*Kmax];	
	k1=new double[NoAngles];
	k2=new double[NoAngles];
	k3=new double[NoAngles];
	memset(p,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(pn,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(RHS,0,sizeof(double)*Imax*Jmax*Kmax);
    memset(pint,0,sizeof(double)*n*n);
	memset(pcountinner,0,sizeof(int)*Imax*Jmax*Kmax);
	memset(pcount,0,sizeof(int)*n*n);

	
	//calIndex(index,Imax,Jmax,Kmax);
	///////////////////Reading parameters//////////////////////////////
	CStdioFile par;
	CString str;
	ofstream log;		
	par.Open("Parameter_DNS.dat",CFile::modeRead);
	par.ReadString(FileLog);
	log.open(FileLog);
	par.ReadString(str);Imax=atoi(str);log<<(str);log<<(_T("  I\n"));
	par.ReadString(str);Jmax=atoi(str);log<<(str);log<<(_T("  J\n"));
	par.ReadString(str);Kmax=atoi(str);log<<(str);log<<(_T("  K\n"));
	par.ReadString(str);deltx=atof(str);log<<(str);log<<(_T("  deltax\n"));
	par.ReadString(str);delty=atof(str);log<<(str);log<<(_T("  deltay\n"));
	par.ReadString(str);deltz=atof(str);log<<(str);log<<(_T("  deltaz\n"));
	par.ReadString(str);rho=atoi(str);log<<(str);log<<(_T("  rho\n"));
	par.ReadString(str);scale=atoi(str);log<<(str);log<<(_T("  scale\n"));
	par.ReadString(str);linespacing=atof(str);log<<(str);log<<(_T("  linespacing\n"));
	par.ReadString(str);NoItr=atoi(str);log<<(str);log<<(_T("  No iteration\n"));
	par.ReadString(str);NoAngles=atoi(str);log<<(str);log<<(_T("  No of Angles\n"));
	par.ReadString(FileAcc);
	par.ReadString(FileSphereGrid);
	par.ReadString(FilePdns);
	par.ReadString(FileOut);
	par.Close();

	CStdioFile fin;		
	////Read Random Numbers;
	cout<<"Reading Unstructured Grids.........."<<endl;
	fin.Open(FileSphereGrid,CFile::modeRead);
	for(int j=0;j<NoAngles;j++)
	{
		long pos;
		fin.ReadString(str);

		pos=str.ReverseFind(' ');
		k3[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k2[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k1[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}
	}
	fin.Close();
	fin.Open(FileAcc,CFile::modeRead);
	//fin.ReadString(str);fin.ReadString(str);fin.ReadString(str);
	cout<<"Reading Acceleration.........."<<endl;
	//fin.ReadString(str);
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				long pos;
				fin.ReadString(str);
				
				pos=str.ReverseFind(' ');
				dwdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}
				
				dvdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				dudt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}
				z[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				y[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				x[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));


			}
		}
	}
	fin.Close();
	///////////Read Acceleration Completed/////////////////


	cout<<"Reading DNS Pressure.........."<<endl;
	//////////Begin read DNS Pressure//////////////////////
	double pmax=0;
	double pmin=0;
	meanpdns=0;
	fin.Open(FilePdns,CFile::modeRead);
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				long pos;
				fin.ReadString(str);
				pos=str.ReverseFind(' ');
				pdns[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				meanpdns+=pdns[i+j*Imax+k*Imax*Jmax];
				if(pdns[i+j*Imax+k*Imax*Jmax]>pmax)
				{
					pmax=pdns[i+j*Imax+k*Imax*Jmax];
				}
				if(pdns[i+j*Imax+k*Imax*Jmax]<pmin)
				{
					pmin=pdns[i+j*Imax+k*Imax*Jmax];
				}
			}
		}
	}
	//meanpdns=meanpdns/n;
	meanpdns=meanpdns/Imax/Jmax/Kmax;
	fin.Close();
	///Integrate for initial pressure
	cout<<"Integration Initial Pressure"<<endl;
	initialIntegration(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,pdns[Imax/2+Jmax/2*Imax+Kmax/2*Imax*Jmax],p,pn,pdns);

	time1=clock();
	log<<"Initialization: "<<time1-st<<'\n';
	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	cudaMalloc((void **)&dudt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&dvdt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&dwdt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&pint_d,sizeof(double)*n*n);
	cudaMalloc((void **)&pcount_d,sizeof(int)*n*n);
	cudaMalloc((void **)&p_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&pn_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&index_d,sizeof(long)*Imax*Jmax*Kmax);
	//cudaMalloc((void**)&pcountitr_d,sizeof(int)*n);
	cudaMalloc((void**)&pcountinner_d,sizeof(int)*Imax*Jmax*Kmax);
	cudaMalloc((void**)&k1_d,sizeof(double)*NoAngles);
	cudaMalloc((void**)&k2_d,sizeof(double)*NoAngles);
	cudaMalloc((void**)&k3_d,sizeof(double)*NoAngles);
	cudaMemset(p_d,0,sizeof(double)*Imax*Jmax*Kmax);
	cudaMemset(pn_d,0,sizeof(double)*Imax*Jmax*Kmax);
	cudaMemset(pint_d,0,sizeof(double)*n*n);
	cudaMemset(pcount_d,0,sizeof(int)*n*n);
	cudaMemset(pcountinner_d,0,sizeof(int)*Imax*Jmax*Kmax);
	//cudaMemset(pcountitr_d,0,sizeof(int)*n);
	cudaMemcpy(dudt_d,dudt,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(dvdt_d,dvdt,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(dwdt_d,dwdt,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(k1_d,k1,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	cudaMemcpy(k2_d,k2,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	cudaMemcpy(k3_d,k3,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	cudaMemcpy(p_d,p,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	//////////////////////End of allocate memory on GPU//////////////
	cudaEventRecord(stop,  0);
	cudaEventElapsedTime(&time, start, stop);
	log<<"Allocating memory on GPU: "<<time;
	cudaEventRecord(start,0);
	cout<<"Calculating Pressure Increment"<<endl;
	dim3 threadPerBlock(16,16);
	dim3 blockPerGrid(4096,4096);
	calIndexGPU<<<n/512,512>>>(index_d,Imax,Jmax,Kmax);
	
	//initialIntegration<<<n/512,512>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//omni3dvirtual<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d);
	//omni3d<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	//omni3dparallellines<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d,pcountinner_d);
	omni3dparallellinesEqualSpacing<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,linespacing,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d,pcountinner_d);
	devidecount<<<n/512,512>>>(Imax,Jmax,Kmax,pint_d,pcount_d);
	//omni3d<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	///omni3dvirtual<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d);
	//omni3virtualgrid<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoTheta,NoBeta,index_d,ninvir_d,noutvir_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pintvir_d);
	//BCiterationvirtualgrid<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoTheta,NoBeta,index_d,ninvir_d,noutvir_d,pintvir_d,p_d,pn_d,1000);
	//omni3dvirtual2<<<4096,512>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	//omni3virtualcpu(Imax,Jmax,Kmax,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount);
	//calIndex(index,Imax,Jmax,Kmax);
	//omni3dparallellinescpu(Imax,Jmax,Kmax,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount);
	//omni3dparallellinesEqualSpacingcpu(Imax,Jmax,Kmax,NoAngles,k1,k2,k3,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount,pcountinner);
	//cudaMemcpy(pint,pint_d,sizeof(double)*n*n,cudaMemcpyDeviceToHost);
	//cudaMemcpy(pcount,pcount_d,sizeof(int)*n*n,cudaMemcpyDeviceToHost);
	////------------couting time------------------////////////
	cudaEventElapsedTime(&time, start, stop);
	log<<"Pressure Increment Calculation: "<<time;
	cudaEventRecord(start,0);
	/////-------------couting time----------------////////////
	//cudaMemcpy(p,p_d,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyDeviceToHost);
	//cudaMemcpy(pcountinner,pcountinner_d,sizeof(int)*Imax*Jmax*Kmax,cudaMemcpyDeviceToHost);
	//meanpcal=BCIterationCPU(Imax,Jmax,Kmax,pint,p,pn,eps,NoItr);
	BCiteration<<<n/512,512>>>(Imax,Jmax,Kmax,pint_d,pcount_d,p_d,pn_d,NoItr);
	cudaMemcpy(p_d,p,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemset(pn_d,0,sizeof(double)*Imax*Jmax*Kmax);
	////------------couting time------------------////////////
	cudaEventElapsedTime(&time, start, stop);
	log<<"Boundary Pressure Iteration: "<<time;
	cudaEventRecord(start,0);
	/////-------------couting time----------------////////////
	omni3dparallellinesESInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,linespacing,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//omni3dparallellinesInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	devidecountInner<<<n/512,512>>>(Imax,Jmax,Kmax,p_d,pn_d,pcountinner_d);
	//cudaMemset(pcountinner_d,0,sizeof(int)*Imax*Jmax*Kmax);
	//omni3dparallellinesESInner2<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d,pcountinner_d);
	//omni3dparallellinesInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//devidecountInner<<<n/512,512>>>(Imax,Jmax,Kmax,p_d,pn_d,pcountinner_d);
	cudaMemcpy(p,p_d,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyDeviceToHost);
	////------------couting time------------------////////////
	cudaEventElapsedTime(&time, start, stop);
	log<<"Inner Pressure Integration: "<<time;
	/////-------------couting time----------------////////////
	
	//cudaMemcpy(pintvir,pintvir_d,sizeof(double)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	//cudaMemcpy(ninvir,ninvir_d,sizeof(long)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	//cudaMemcpy(noutvir,noutvir_d,sizeof(long)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	cout<<"Iteration to get boundary pressure.........."<<endl;
	time1=clock();

	//meanpcal=BCIterationCPU(Imax,Jmax,Kmax,pint,p,pn,eps,200);
	// check for error
	cudaError_t error = cudaGetLastError();
	if(error != cudaSuccess)
	{
		// print the CUDA error message and exit
		printf("CUDA error: %s\n", cudaGetErrorString(error));
	}

	CStdioFile fout;		
	fout.Open(FileOut,CFile::modeWrite|CFile::modeCreate);
	////////////////////Write Data to file////////////////////
	///////////Apply 3D SOR iteration////////////////////////////////////////////
	//calRHS(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,RHS);
	//int BC[6]={1,1,1,1,1,1};
	//sor3D(Imax,Jmax,Kmax,2000,BC,x,y,z,p,pn,RHS,eps);
	cout<<"Iteration for inner nodes............."<<endl;
	//omni3Dinner(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,pcountinner,p,pn,20);

	////////////////Restirct mean value to be 0//////////////////////
	meanpcal=0;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{			
					meanpcal+=p[i+j*Imax+k*Imax*Jmax];			
			}
		}
	}
	//meanpcal=meanpcal/n;
	meanpcal=meanpcal/Imax/Jmax/Kmax;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				p[i+j*Imax+k*Imax*Jmax]=p[i+j*Imax+k*Imax*Jmax]-meanpcal;
			}
		}
	}
	
	/////////////Iteration completed/////////////////////////////////////////////
	cout<<"Writing Pressure Boundary...."<<endl;
	fout.WriteString("TITLE = \"Pressure Integrated From GPU Based Omni 3D Method\"\n");
	fout.WriteString("VARIABLES = \"X\",\"Y\",\"Z\",\"Pcal\",\"Pdns\",\"Pdiffrela\",\"Pcount\"\n");
	str.Format(_T("ZONE I=%i, J=%i, K=%i,F=POINT\n"),Imax,Jmax,Kmax);
	fout.WriteString(str);
	//pmax=1;meanpdns=0;
	double pabsmax=0;
	double prmserror=0;
	if(meanpdns>0)
	{
		if(pmax>abs(pmin))
		{
			pabsmax=pmax-meanpdns;
		}
		else
		{
			pabsmax=abs(pmin)+meanpdns;
		}
	}
	else
	{
		if(pmax>abs(pmin))
		{
			pabsmax=pmax-meanpdns;
		}
		else
		{
			pabsmax=abs(pmin)+meanpdns;
		}
	}

	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				str.Format(_T("%f %f %f %f %f %f %d\n"),x[i+j*Imax+k*Imax*Jmax],y[i+j*Imax+k*Imax*Jmax],z[i+j*Imax+k*Imax*Jmax],p[i+j*Imax+k*Imax*Jmax],pdns[i+j*Imax+k*Imax*Jmax]-meanpdns,(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax,pcountinner[i+j*Imax+k*Imax*Jmax]);
				prmserror+=(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax*(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax;
				fout.WriteString(str);
			}
		}
	}
	prmserror=sqrt(prmserror/Imax/Jmax/Kmax);
	fout.Close();
	str.Format(_T("rms error: %f\n"),prmserror);
	log<<(str);
	str.Format(_T("Time elasped: %d ms\n"),(clock()- st));
	log<<(str);
	/*fout.Open("PressureIncrementlines16GPU.dat",CFile::modeWrite|CFile::modeCreate);
	////////////////////Write Data to file////////////////////
	cout<<"Writing Files"<<endl;
	str.Format(_T("ZONE I=%i, J=%i, K=1,F=POINT\n"),n,n);
	fout.WriteString(str);
	
		for(long nout=0;nout<n;nout++)
		{
			for(long nin=0;nin<n;nin++)
			{
				int iin,jin,kin;
				int iout,jout,kout;
				ntoijk(Imax,Jmax,Kmax,nin,&iin,&jin,&kin);
				ntoijk(Imax,Jmax,Kmax,nout,&iout,&jout,&kout);
				str.Format(_T("%d %d %d %d %d %d %d %d %f %d\n"),nin,nout,iin,jin,kin,iout,jout,kout,pint[nin+nout*n],pcount[nin+nout*n]);
				//str.Format(_T("%d %d %d %d %f\n"),nin,nout,ninvir[nin+nout*NoTheta*NoBeta],noutvir[nin+nout*NoTheta*NoBeta],pintvir[nin+nout*NoTheta*NoBeta]);
				fout.WriteString(str);
			}
		}
	

	fout.Close();*/
	time2=clock();
	log<<"Output time: "<<time2-time1<<'\n';
	log<<"Total time: "<<time2-st<<'\n';
	log.close();
	delete []x,y,z,u,v,w,dudt,dvdt,dwdt,pint,p,pn,pdns,RHS,pcount,pcountinner,k1,k2,k3;
	cudaFree(dudt_d);
	cudaFree(dvdt_d);
	cudaFree(dwdt_d);
	cudaFree(pint_d);
	cudaFree(pcount_d);
	cudaFree(p_d);
	cudaFree(pn_d);
	cudaFree(pcountinner_d);
	cudaFree(k1_d);
	cudaFree(k2_d);
	cudaFree(k3_d);
	cudaDeviceReset();
	exit(true ? EXIT_SUCCESS : EXIT_FAILURE);
    return 0;
}

///////////////////////////For DNS Verification  on CPU//////////////////////////////////
/*
int main()
{
	cudaDeviceProp prop;
	long DeviceNo=0;
	cudaSetDevice(DeviceNo);
	cudaGetDeviceProperties( &prop, DeviceNo ) ;
	printf( " ----------- General Information for device %d --------\n", DeviceNo );
	printf( "Name: %s\n", prop.name );
	printf( "Compute capability: %d.%d\n", prop.major, prop.minor );
	printf( "Clock rate: %d\n", prop.clockRate );
	printf( "Device copy overlap: " );
	if (prop.deviceOverlap)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( "Kernel execition timeout : " );
	if (prop.kernelExecTimeoutEnabled)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( " ------------ Memory Information for device %d ---------\n", DeviceNo );
	printf( "Total global mem: %ld\n", prop.totalGlobalMem );
	printf( "Total constant Mem: %ld\n", prop.totalConstMem );
	printf( "Max mem pitch: %ld\n", prop.memPitch );
	printf( "Texture Alignment: %ld\n", prop.textureAlignment );
	printf( " --- MP Information for device %d ---\n", DeviceNo );
	printf( "Multiprocessor count: %d\n",
		prop.multiProcessorCount );
	printf( "Shared mem per mp: %ld\n", prop.sharedMemPerBlock );
	printf( "Registers per mp: %d\n", prop.regsPerBlock );
	printf( "Threads in warp: %d\n", prop.warpSize );
	printf( "Max threads per block: %d\n",
		prop.maxThreadsPerBlock );
	printf( "Max thread dimensions: (%d, %d, %d)\n",
		prop.maxThreadsDim[0], prop.maxThreadsDim[1],
		prop.maxThreadsDim[2] );
	printf( "Max grid dimensions: (%d, %d, %d)\n",
		prop.maxGridSize[0], prop.maxGridSize[1],
		prop.maxGridSize[2] );
	printf( "\n" );
	long Imax,Jmax,Kmax,n,PlaneSt,Planedt,PlaneEnd,FileNumSt,FileNumDelt,FileNumEnd;
	clock_t start;
	start=clock();
	double rho,scale;
	double density=1;
	double eps=1e-10;
	double meanpcal=0;
	double meanpdns=0;
	double* x,*y,*z,*u,*v,*w,*dudt,*dvdt,*dwdt,*pint,*p,*pn,*pdns,*RHS;
	double* k1,*k2,*k3;
	double linespacing;
	long *index;
	int *pcountinner;
	int *pcount;
	int NoAngles=10000;
	int NoItr=200;
	CString FileAcc=_T("Force.dat");
	CString FileSphereGrid=_T("radomnumber.dat");
	CString FilePdns=_T("P64.dat");
	CString FileOut=_T("Pressure.dat");
	CString FileLog=_T("Log.dat");
	Imax=64;
	Jmax=64;
	Kmax=64;
	double deltx=0.006135923151543;
	double delty=0.006135923151543;
	double deltz=0.006135923151543;
	linespacing=1;
	n=Imax*Jmax*2+(Jmax-2)*Kmax*2+(Imax-2)*(Kmax-2)*2;
	x=new double[Imax*Jmax*Kmax];
	y=new double[Imax*Jmax*Kmax];
	z=new double[Imax*Jmax*Kmax];
	u=new double[Imax*Jmax*Kmax];
	v=new double[Imax*Jmax*Kmax];
	w=new double[Imax*Jmax*Kmax];
	dudt=new double[Imax*Jmax*Kmax];
	dvdt=new double[Imax*Jmax*Kmax];
	dwdt=new double[Imax*Jmax*Kmax];
	p=new double[Imax*Jmax*Kmax];
	pn=new double[Imax*Jmax*Kmax];
	pdns=new double[Imax*Jmax*Kmax];
	RHS=new double[Imax*Jmax*Kmax];
	pint=new double[n*n];
	pcountinner=new int[Imax*Jmax*Kmax];
	pcount=new int[n*n];
	index=new long[Imax*Jmax*Kmax];	
	k1=new double[NoAngles];
	k2=new double[NoAngles];
	k3=new double[NoAngles];
	memset(p,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(pn,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(RHS,0,sizeof(double)*Imax*Jmax*Kmax);
    memset(pint,0,sizeof(double)*n*n);
	memset(pcountinner,0,sizeof(int)*Imax*Jmax*Kmax);
	memset(pcount,0,sizeof(int)*n*n);
	//calIndex(index,Imax,Jmax,Kmax);
	///////////////////Reading parameters//////////////////////////////
	CStdioFile par;
	CString str;
	CStdioFile log;		
	par.Open("Parameter_DNS.dat",CFile::modeRead);
	par.ReadString(FileLog);
	log.Open(FileLog,CFile::modeWrite|CFile::modeCreate);
	par.ReadString(str);Imax=atoi(str);log.WriteString(str);log.WriteString(_T("  I\n"));
	par.ReadString(str);Jmax=atoi(str);log.WriteString(str);log.WriteString(_T("  J\n"));
	par.ReadString(str);Kmax=atoi(str);log.WriteString(str);log.WriteString(_T("  K\n"));
	par.ReadString(str);deltx=atof(str);log.WriteString(str);log.WriteString(_T("  deltax\n"));
	par.ReadString(str);delty=atof(str);log.WriteString(str);log.WriteString(_T("  deltay\n"));
	par.ReadString(str);deltz=atof(str);log.WriteString(str);log.WriteString(_T("  deltaz\n"));
	par.ReadString(str);rho=atoi(str);log.WriteString(str);log.WriteString(_T("  rho\n"));
	par.ReadString(str);scale=atoi(str);log.WriteString(str);log.WriteString(_T("  scale\n"));
	par.ReadString(str);linespacing=atof(str);log.WriteString(str);log.WriteString(_T("  linespacing\n"));
	par.ReadString(str);NoItr=atoi(str);log.WriteString(str);log.WriteString(_T("  No iteration\n"));
	par.ReadString(str);NoAngles=atoi(str);log.WriteString(str);log.WriteString(_T("  No of Angles\n"));
	par.ReadString(FileAcc);
	par.ReadString(FileSphereGrid);
	par.ReadString(FilePdns);
	par.ReadString(FileOut);
	par.Close();



	CStdioFile fin;		
	////Read Random Numbers;
	cout<<"Reading Random Number.........."<<endl;
	fin.Open(FileSphereGrid,CFile::modeRead);
	for(int j=0;j<NoAngles;j++)
	{
		long pos;
		fin.ReadString(str);

		pos=str.ReverseFind(' ');
		k3[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k2[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k1[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}
	}
	fin.Close();
	fin.Open(FileAcc,CFile::modeRead);
	//fin.ReadString(str);fin.ReadString(str);fin.ReadString(str);
	cout<<"Reading Acceleration.........."<<endl;
	//fin.ReadString(str);
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				long pos;
				fin.ReadString(str);
				
				pos=str.ReverseFind(' ');
				dwdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}
				
				dvdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				dudt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}
				z[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				y[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				x[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));


			}
		}
	}
	fin.Close();
	///////////Read Acceleration Completed/////////////////
	cout<<"Reading DNS Pressure.........."<<endl;
	//////////Begin read DNS Pressure//////////////////////
	double pmax=0;
	double pmin=0;
	meanpdns=0;
	fin.Open(FilePdns,CFile::modeRead);
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				long pos;
				fin.ReadString(str);
				pos=str.ReverseFind(' ');
				pdns[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				meanpdns+=pdns[i+j*Imax+k*Imax*Jmax];
				if(pdns[i+j*Imax+k*Imax*Jmax]>pmax)
				{
					pmax=pdns[i+j*Imax+k*Imax*Jmax];
				}
				if(pdns[i+j*Imax+k*Imax*Jmax]<pmin)
				{
					pmin=pdns[i+j*Imax+k*Imax*Jmax];
				}
			}
		}
	}
	//meanpdns=meanpdns/n;
	meanpdns=meanpdns/Imax/Jmax/Kmax;
	fin.Close();
	///Integrate for initial pressure
	cout<<"Integration Initial Pressure"<<endl;
	initialIntegration(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,pdns[Imax/2+Jmax/2*Imax+Kmax/2*Imax*Jmax],p,pn,pdns);


	/////////////////////////////////////////////////////////////////////////////////////////////////////////

	//////////////////////End of allocate memory on GPU//////////////
	cout<<"Calculating Pressure Increment"<<endl;
	calIndex(index,Imax,Jmax,Kmax);
	omni3dparallellinescpu(Imax,Jmax,Kmax,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount);
	devidecountCPU(Imax,Jmax,Kmax,pint,pcount);
	BCIterationCPU(Imax,Jmax,Kmax,pint,p,pn,eps,NoItr);
	omni3dparallellinesESInnerCPU(Imax,Jmax,Kmax,NoAngles,linespacing,k1,k2,k3,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,p,pn);
	devidecountInnerCPU(Imax,Jmax,Kmax,p,pn,pcountinner);
	cout<<"Iteration to get boundary pressure.........."<<endl;
	CStdioFile fout;		
	fout.Open(FileOut,CFile::modeWrite|CFile::modeCreate);
	////////////////////Write Data to file////////////////////
	
	cout<<"Iteration for inner nodes............."<<endl;
	
	////////////////Restirct mean value to be 0//////////////////////
	meanpcal=0;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{			
					meanpcal+=p[i+j*Imax+k*Imax*Jmax];			
			}
		}
	}
	//meanpcal=meanpcal/n;
	meanpcal=meanpcal/Imax/Jmax/Kmax;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				p[i+j*Imax+k*Imax*Jmax]=p[i+j*Imax+k*Imax*Jmax]-meanpcal;
			}
		}
	}
	
	/////////////Iteration completed/////////////////////////////////////////////
	cout<<"Writing Pressure Boundary...."<<endl;
	fout.WriteString("TITLE = \"Pressure Integrated From GPU Based Omni 3D Method\"\n");
	fout.WriteString("VARIABLES = \"X\",\"Y\",\"Z\",\"Pcal\",\"Pdns\",\"Pdiffrela\",\"Pcount\"\n");
	str.Format(_T("ZONE I=%i, J=%i, K=%i,F=POINT\n"),Imax,Jmax,Kmax);
	fout.WriteString(str);
	//pmax=1;meanpdns=0;
	double pabsmax=0;
	double prmserror=0;
	if(meanpdns>0)
	{
		if(pmax>abs(pmin))
		{
			pabsmax=pmax-meanpdns;
		}
		else
		{
			pabsmax=abs(pmin)+meanpdns;
		}
	}
	else
	{
		if(pmax>abs(pmin))
		{
			pabsmax=pmax-meanpdns;
		}
		else
		{
			pabsmax=abs(pmin)+meanpdns;
		}
	}

	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				str.Format(_T("%f %f %f %f %f %f %d\n"),x[i+j*Imax+k*Imax*Jmax],y[i+j*Imax+k*Imax*Jmax],z[i+j*Imax+k*Imax*Jmax],p[i+j*Imax+k*Imax*Jmax],pdns[i+j*Imax+k*Imax*Jmax]-meanpdns,(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax,pcountinner[i+j*Imax+k*Imax*Jmax]);
				prmserror+=(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax*(pdns[i+j*Imax+k*Imax*Jmax]-p[i+j*Imax+k*Imax*Jmax]-meanpdns)/pabsmax;
				fout.WriteString(str);
			}
		}
	}
	prmserror=sqrt(prmserror/Imax/Jmax/Kmax);
	fout.Close();
	str.Format(_T("rms error: %f\n"),prmserror);
	log.WriteString(str);
	str.Format(_T("Time elasped: %d ms\n"),(clock()- start ));
	log.WriteString(str);
	log.Close();
	/*fout.Open("PressureIncrementlines16GPU.dat",CFile::modeWrite|CFile::modeCreate);
	////////////////////Write Data to file////////////////////
	cout<<"Writing Files"<<endl;
	str.Format(_T("ZONE I=%i, J=%i, K=1,F=POINT\n"),n,n);
	fout.WriteString(str);
	
		for(long nout=0;nout<n;nout++)
		{
			for(long nin=0;nin<n;nin++)
			{
				int iin,jin,kin;
				int iout,jout,kout;
				ntoijk(Imax,Jmax,Kmax,nin,&iin,&jin,&kin);
				ntoijk(Imax,Jmax,Kmax,nout,&iout,&jout,&kout);
				str.Format(_T("%d %d %d %d %d %d %d %d %f %d\n"),nin,nout,iin,jin,kin,iout,jout,kout,pint[nin+nout*n],pcount[nin+nout*n]);
				//str.Format(_T("%d %d %d %d %f\n"),nin,nout,ninvir[nin+nout*NoTheta*NoBeta],noutvir[nin+nout*NoTheta*NoBeta],pintvir[nin+nout*NoTheta*NoBeta]);
				fout.WriteString(str);
			}
		}
	

	fout.Close();
	delete []x,y,z,u,v,w,dudt,dvdt,dwdt,pint,p,pn,pdns,RHS,pcount,pcountinner,k1,k2,k3;
    return 0;
}*/
/////////////////////////////For Experimental Data Version///////////////////////////////
/*
int main()
{
	cudaDeviceProp prop;
	long DeviceNo=0;
	cudaSetDevice(DeviceNo);
	cudaGetDeviceProperties( &prop, DeviceNo ) ;
	printf( " ----------- General Information for device %d --------\n", DeviceNo );
	printf( "Name: %s\n", prop.name );
	printf( "Compute capability: %d.%d\n", prop.major, prop.minor );
	printf( "Clock rate: %d\n", prop.clockRate );
	printf( "Device copy overlap: " );
	if (prop.deviceOverlap)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( "Kernel execition timeout : " );
	if (prop.kernelExecTimeoutEnabled)
		printf( "Enabled\n" );
	else
		printf( "Disabled\n" );
	printf( " ------------ Memory Information for device %d ---------\n", DeviceNo );
	printf( "Total global mem: %ld\n", prop.totalGlobalMem );
	printf( "Total constant Mem: %ld\n", prop.totalConstMem );
	printf( "Max mem pitch: %ld\n", prop.memPitch );
	printf( "Texture Alignment: %ld\n", prop.textureAlignment );
	printf( " --- MP Information for device %d ---\n", DeviceNo );
	printf( "Multiprocessor count: %d\n",
		prop.multiProcessorCount );
	printf( "Shared mem per mp: %ld\n", prop.sharedMemPerBlock );
	printf( "Registers per mp: %d\n", prop.regsPerBlock );
	printf( "Threads in warp: %d\n", prop.warpSize );
	printf( "Max threads per block: %d\n",
		prop.maxThreadsPerBlock );
	printf( "Max thread dimensions: (%d, %d, %d)\n",
		prop.maxThreadsDim[0], prop.maxThreadsDim[1],
		prop.maxThreadsDim[2] );
	printf( "Max grid dimensions: (%d, %d, %d)\n",
		prop.maxGridSize[0], prop.maxGridSize[1],
		prop.maxGridSize[2] );
	printf( "\n" );
	long Imax,Jmax,Kmax,n,PlaneSt,Planedt,PlaneEnd,FileNumSt,FileNumDelt,FileNumEnd;
	double rho,scale;
	double density=1;
	double eps=1e-10;
	double meanpcal=0;
	double meanpdns=0;
	double* x,*y,*z,*u,*v,*w,*dudt,*dvdt,*dwdt,*pint,*p,*pn,*pdns,*RHS;
	double* k1,*k2,*k3;
	double* dudt_d,*dvdt_d,*dwdt_d,*pint_d,*p_d,*pn_d;
	double* k1_d,*k2_d,*k3_d;
	long *index,*index_d;
	int *pcountinner,*pcountinner_d;
	int* pcount_d,*pcountitr_d,*pcount;
	int NoAngles=10000;
	int NoItr=100;
	int cutz;
	int cutx;
	int cuty;
	Imax=64;
	Jmax=64;
	Kmax=64;
	double deltx=0.006135923151543;
	double delty=0.006135923151543;
	double deltz=0.006135923151543;
	CString pathpressure,pathacc,fileacc,basefile;
	///////////////////Reading parameters//////////////////////////////
	CStdioFile par;
	CString str;
	par.Open("parameter_Omni.dat",CFile::modeRead);
	par.ReadString(str);Imax=atoi(str);
	par.ReadString(str);Jmax=atoi(str);
	par.ReadString(str);Kmax=atoi(str);
	par.ReadString(str);deltx=atof(str);
	par.ReadString(str);delty=atof(str);
	par.ReadString(str);deltz=atof(str);
	par.ReadString(str);rho=atoi(str);
	par.ReadString(str);scale=atoi(str);
	par.ReadString(pathacc);
	par.ReadString(basefile);
	par.ReadString(pathpressure);
	par.ReadString(str);FileNumSt=atof(str);
	par.ReadString(str);FileNumDelt=atof(str);
	par.ReadString(str);FileNumEnd=atof(str);
	par.ReadString(str);NoItr=atoi(str);
	par.ReadString(str);cutx=atoi(str);
	par.ReadString(str);cuty=atoi(str);
	par.ReadString(str);cutz=atoi(str);
	par.Close();
	////////////////////////////////Reading parameter completed////////////////////////
	
	
	x=new double[Imax*Jmax*Kmax];
	y=new double[Imax*Jmax*Kmax];
	z=new double[Imax*Jmax*Kmax];
	u=new double[Imax*Jmax*Kmax];
	v=new double[Imax*Jmax*Kmax];
	w=new double[Imax*Jmax*Kmax];
	
	dudt=new double[Imax*Jmax*Kmax];
	dvdt=new double[Imax*Jmax*Kmax];
	dwdt=new double[Imax*Jmax*Kmax];
	Kmax=Kmax-cut;
	n=Imax*Jmax*2+(Jmax-2)*Kmax*2+(Imax-2)*(Kmax-2)*2;
	p=new double[Imax*Jmax*Kmax];
	pn=new double[Imax*Jmax*Kmax];
	pdns=new double[Imax*Jmax*Kmax];
	RHS=new double[Imax*Jmax*Kmax];
	pint=new double[n*n];
	pcountinner=new int[Imax*Jmax*Kmax];
	pcount=new int[n*n];
	index=new long[Imax*Jmax*Kmax];	
	k1=new double[NoAngles];
	k2=new double[NoAngles];
	k3=new double[NoAngles];
	memset(p,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(pn,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(RHS,0,sizeof(double)*Imax*Jmax*Kmax);
	memset(pint,0,sizeof(double)*n*n);
	memset(pcountinner,0,sizeof(int)*Imax*Jmax*Kmax);
	memset(pcount,0,sizeof(int)*n*n);
	//calIndex(index,Imax,Jmax,Kmax);
	CStdioFile fin;		
	////Read Random Numbers;
	cout<<"Reading Randm Number.........."<<endl;
	fin.Open("radomnumber.dat",CFile::modeRead);
	for(int j=0;j<NoAngles;j++)
	{
		long pos;
		fin.ReadString(str);

		pos=str.ReverseFind(' ');
		k3[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k2[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}

		k1[j]=atof(str.Right(str.GetLength()-pos-1));
		for(long m=0;m<1;m++)
		{
			str=str.Left(pos);
			pos=str.ReverseFind(' ');
		}
	}
	fin.Close();
	///////////////////////////////////////////////
	cudaMalloc((void **)&dudt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&dvdt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&dwdt_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&pint_d,sizeof(double)*n*n);
	cudaMalloc((void **)&pcount_d,sizeof(int)*n*n);
	cudaMalloc((void **)&p_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&pn_d,sizeof(double)*Imax*Jmax*Kmax);
	cudaMalloc((void **)&index_d,sizeof(long)*Imax*Jmax*Kmax);
	//cudaMalloc((void**)&pcountitr_d,sizeof(int)*n);
	cudaMalloc((void**)&pcountinner_d,sizeof(int)*Imax*Jmax*Kmax);
	cudaMalloc((void**)&k1_d,sizeof(double)*NoAngles);
	cudaMalloc((void**)&k2_d,sizeof(double)*NoAngles);
	cudaMalloc((void**)&k3_d,sizeof(double)*NoAngles);
	
	
	//////////////////////End of allocate memory on GPU//////////////	
	for(int FileNum=FileNumSt;FileNum<=FileNumEnd;FileNum=FileNum+FileNumDelt)
	{
		fileacc=pathacc;
		fileacc.Append(basefile);
		fileacc.AppendFormat(_T("%.5d.dat"),FileNum);
		fin.Open(fileacc,CFile::modeRead);
		fin.ReadString(str);fin.ReadString(str);fin.ReadString(str);
		
	//fin.ReadString(str);fin.ReadString(str);fin.ReadString(str);
	cout<<"Reading Acceleration.........."<<endl;
	Kmax=Kmax+cut;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				long pos;
				fin.ReadString(str);
				
				pos=str.ReverseFind(' ');
				dwdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}
				
				dvdt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				dudt[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				w[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				str=str.Left(pos);
				pos=str.ReverseFind(' ');
				v[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				str=str.Left(pos);
				pos=str.ReverseFind(' ');
				u[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				str=str.Left(pos);
				pos=str.ReverseFind(' ');
				z[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				y[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));
				for(long m=0;m<1;m++)
				{
					str=str.Left(pos);
					pos=str.ReverseFind(' ');
				}

				x[i+j*Imax+k*Imax*Jmax]=atof(str.Right(str.GetLength()-pos-1));


			}
		}
	}
	fin.Close();
	Kmax=Kmax-cutz;
	cudaMemset(p_d,0,sizeof(double)*Imax*Jmax*Kmax);
	cudaMemset(pn_d,0,sizeof(double)*Imax*Jmax*Kmax);
	cudaMemset(pint_d,0,sizeof(double)*n*n);
	cudaMemset(pcount_d,0,sizeof(int)*n*n);
	cudaMemset(pcountinner_d,0,sizeof(int)*Imax*Jmax*Kmax);
	//cudaMemset(pcountitr_d,0,sizeof(int)*n);
	cudaMemcpy(dudt_d,&dudt[Imax*Jmax*cut/2],sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(dvdt_d,&dvdt[Imax*Jmax*cut/2],sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(dwdt_d,&dwdt[Imax*Jmax*cut/2],sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	cudaMemcpy(k1_d,k1,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	cudaMemcpy(k2_d,k2,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	cudaMemcpy(k3_d,k3,sizeof(double)*NoAngles,cudaMemcpyHostToDevice);
	//cudaMemcpy(p_d,p,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyHostToDevice);
	//////////////////////End of allocate memory on GPU//////////////
	cout<<"Calculating Pressure Increment"<<endl;
	dim3 threadPerBlock(16,16);
	dim3 blockPerGrid(4096,4096);
	calIndexGPU<<<n/512,512>>>(index_d,Imax,Jmax,Kmax);
	//initialIntegration<<<n/512,512>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//omni3dvirtual<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d);
	//omni3d<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	//omni3dparallellines<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d,pcountinner_d);
	omni3dparallellinesEqualSpacing<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d,pcountinner_d);
	devidecount<<<n/512,512>>>(Imax,Jmax,Kmax,pint_d,pcount_d);
	//omni3d<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	///omni3dvirtual<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d,pcount_d);
	//omni3virtualgrid<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoTheta,NoBeta,index_d,ninvir_d,noutvir_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pintvir_d);
	//BCiterationvirtualgrid<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoTheta,NoBeta,index_d,ninvir_d,noutvir_d,pintvir_d,p_d,pn_d,1000);
	//omni3dvirtual2<<<4096,512>>>(Imax,Jmax,Kmax,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,pint_d);
	//omni3virtualcpu(Imax,Jmax,Kmax,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount);
	//calIndex(index,Imax,Jmax,Kmax);
	//omni3dparallellinescpu(Imax,Jmax,Kmax,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount);
	//omni3dparallellinesEqualSpacingcpu(Imax,Jmax,Kmax,NoAngles,k1,k2,k3,index,deltx,delty,deltz,density,dudt,dvdt,dwdt,pint,pcount,pcountinner);
	BCiteration<<<n/512,512>>>(Imax,Jmax,Kmax,pint_d,pcount_d,p_d,pn_d,NoItr);
	omni3dparallellinesESInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//omni3dparallellinesInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	devidecountInner<<<n/512,512>>>(Imax,Jmax,Kmax,p_d,pn_d,pcountinner_d);
	//cudaMemset(pcountinner_d,0,sizeof(int)*Imax*Jmax*Kmax);
	//omni3dparallellinesESInner2<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d,pcountinner_d);
	//omni3dparallellinesInner<<<blockPerGrid,threadPerBlock>>>(Imax,Jmax,Kmax,NoAngles,k1_d,k2_d,k3_d,index_d,deltx,delty,deltz,density,dudt_d,dvdt_d,dwdt_d,p_d,pn_d);
	//devidecountInner<<<n/512,512>>>(Imax,Jmax,Kmax,p_d,pn_d,pcountinner_d);
	cudaMemcpy(pint,pint_d,sizeof(double)*n*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(pcount,pcount_d,sizeof(int)*n*n,cudaMemcpyDeviceToHost);
	cudaMemcpy(p,p_d,sizeof(double)*Imax*Jmax*Kmax,cudaMemcpyDeviceToHost);
	cudaMemcpy(pcountinner,pcountinner_d,sizeof(int)*Imax*Jmax*Kmax,cudaMemcpyDeviceToHost);
	//cudaMemcpy(pintvir,pintvir_d,sizeof(double)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	//cudaMemcpy(ninvir,ninvir_d,sizeof(long)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	//cudaMemcpy(noutvir,noutvir_d,sizeof(long)*NoTheta*NoBeta*NoTheta*NoBeta,cudaMemcpyDeviceToHost);
	cout<<"Iteration to get boundary pressure.........."<<endl;
	//meanpcal=BCIterationCPU(Imax,Jmax,Kmax,pint,p,pn,eps,200);
	// check for error
	cudaError_t error = cudaGetLastError();
	if(error != cudaSuccess)
	{
		// print the CUDA error message and exit
		printf("CUDA error: %s\n", cudaGetErrorString(error));
	}

	CStdioFile fout;	
	CString outfile=pathpressure;
	outfile.AppendFormat(_T("Pressure3D_%05d.dat"),FileNum);
	fout.Open(outfile,CFile::modeWrite|CFile::modeCreate);
	////////////////////Write Data to file////////////////////
	///////////Apply 3D SOR iteration////////////////////////////////////////////
	//calRHS(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,RHS);
	//int BC[6]={1,1,1,1,1,1};
	//sor3D(Imax,Jmax,Kmax,2000,BC,x,y,z,p,pn,RHS,eps);
	cout<<"Iteration for inner nodes............."<<endl;
	//omni3Dinner(Imax,Jmax,Kmax,deltx,delty,deltz,density,dudt,dvdt,dwdt,pcountinner,p,pn,20);

	////////////////Restirct mean value to be 0//////////////////////
	meanpcal=0;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{			
				meanpcal+=p[i+j*Imax+k*Imax*Jmax];			
			}
		}
	}
	//meanpcal=meanpcal/n;
	meanpcal=meanpcal/Imax/Jmax/Kmax;
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				p[i+j*Imax+k*Imax*Jmax]=p[i+j*Imax+k*Imax*Jmax]-meanpcal;
			}
		}
	}

	/////////////Iteration completed/////////////////////////////////////////////
	cout<<"Writing Pressure Boundary...."<<endl;
	fout.WriteString("TITLE = \"Pressure Integrated From GPU Based Omni 3D Method\"\n");
	fout.WriteString("VARIABLES = \"X\",\"Y\",\"Z\",\"P\",\"Pcount\"\n");
	str.Format(_T("ZONE I=%i, J=%i, K=%i,F=POINT\n"),Imax,Jmax,Kmax);
	fout.WriteString(str);
	//pmax=1;meanpdns=0;
	
	for(long k=0;k<Kmax;k++)
	{
		for(long j=0;j<Jmax;j++)
		{
			for(long i=0;i<Imax;i++)
			{
				str.Format(_T("%f %f %f %f %d\n"),x[i+j*Imax+k*Imax*Jmax],y[i+j*Imax+k*Imax*Jmax],z[i+j*Imax+k*Imax*Jmax],p[i+j*Imax+k*Imax*Jmax],pcountinner[i+j*Imax+k*Imax*Jmax]);
				fout.WriteString(str);
			}
		}
	}

	fout.Close();
	
	
	}
	delete []x,y,z,u,v,w,dudt,dvdt,dwdt,pint,p,pn,pdns,RHS,pcount,pcountinner,k1,k2,k3;
	cudaFree(dudt_d);
	cudaFree(dvdt_d);
	cudaFree(dwdt_d);
	cudaFree(pint_d);
	cudaFree(pcount_d);
	cudaFree(p_d);
	cudaFree(pn_d);
	cudaFree(pcountinner_d);
	cudaFree(k1_d);
	cudaFree(k2_d);
	cudaFree(k3_d);
	cudaDeviceReset();
	exit(true ? EXIT_SUCCESS : EXIT_FAILURE);
	return 0;
}
*/
