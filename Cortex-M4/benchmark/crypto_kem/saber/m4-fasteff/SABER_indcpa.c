#include <string.h>
#include <stdint.h>
#include "SABER_indcpa.h"
#include "poly.h"
#include "pack_unpack.h"
#include "poly_mul.h"
#include "fips202.h"
#include "SABER_params.h"
#include "randombytes.h"



/*-----------------------------------------------------------------------------------
	This routine generates a=[Matrix K x K] of 256-coefficient polynomials 
-------------------------------------------------------------------------------------*/

#define h1 4 //2^(EQ-EP-1)

#define h2 ( (1<<(SABER_EP-2)) - (1<<(SABER_EP-SABER_ET-1)) + (1<<(SABER_EQ-SABER_EP-1)) )

#if MUL_TYPE == TC_TC
	void MatrixVectorMul(polyvec *a, uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16], uint16_t res[SABER_K][SABER_N], uint16_t mod, int16_t transpose);
	void InnerProd(uint16_t pkcl[SABER_K][SABER_N],	uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16],uint16_t mod,uint16_t res[SABER_N]);


#elif MUL_TYPE == TC_KARA
	void MatrixVectorMul(polyvec *a, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t res[SABER_K][SABER_N], uint16_t mod, int16_t transpose);
	void InnerProd(uint16_t pkcl[SABER_K][SABER_N],	uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t mod,uint16_t res[SABER_N]);

#endif

void MatrixVectorMul_keypair(const unsigned char *seed, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t res[SABER_K][SABER_N]);
void MatrixVectorMul_encryption(const unsigned char *seed, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], unsigned char *ciphertext);

void VectorMul(const unsigned char *byte_array, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N],uint16_t res[SABER_N]);

void POL2MSG(uint16_t *message_dec_unpacked, unsigned char *message_dec);

void byte_bank2pol_part(unsigned char *bytes, uint16_t pol_part[], uint16_t pol_part_start_index, uint16_t num_8coeff)
{
	uint32_t j;
	uint32_t offset_data=0, offset_byte=0;	
	
	offset_byte=0;

	for(j=0;j<num_8coeff;j++)
	{
		offset_byte=13*j;
		offset_data=pol_part_start_index+8*j;
		pol_part[offset_data + 0]= ( bytes[ offset_byte + 0 ] & (0xff)) | ((bytes[offset_byte + 1] & 0x1f)<<8);
		pol_part[offset_data + 1]= ( bytes[ offset_byte + 1 ]>>5 & (0x07)) | ((bytes[offset_byte + 2] & 0xff)<<3) | ((bytes[offset_byte + 3] & 0x03)<<11);
		pol_part[offset_data + 2]= ( bytes[ offset_byte + 3 ]>>2 & (0x3f)) | ((bytes[offset_byte + 4] & 0x7f)<<6);
		pol_part[offset_data + 3]= ( bytes[ offset_byte + 4 ]>>7 & (0x01)) | ((bytes[offset_byte + 5] & 0xff)<<1) | ((bytes[offset_byte + 6] & 0x0f)<<9);
		pol_part[offset_data + 4]= ( bytes[ offset_byte + 6 ]>>4 & (0x0f)) | ((bytes[offset_byte + 7] & 0xff)<<4) | ((bytes[offset_byte + 8] & 0x01)<<12);
		pol_part[offset_data + 5]= ( bytes[ offset_byte + 8]>>1 & (0x7f)) | ((bytes[offset_byte + 9] & 0x3f)<<7);
		pol_part[offset_data + 6]= ( bytes[ offset_byte + 9]>>6 & (0x03)) | ((bytes[offset_byte + 10] & 0xff)<<2) | ((bytes[offset_byte + 11] & 0x07)<<10);
		pol_part[offset_data + 7]= ( bytes[ offset_byte + 11]>>3 & (0x1f)) | ((bytes[offset_byte + 12] & 0xff)<<5);
	}
}

void GenMatrix(polyvec *a, const unsigned char *seed) 
{
#if Saber_type == 3
	unsigned char shake_op_buf[SHAKE128_RATE+144];
#else	
	unsigned char shake_op_buf[SHAKE128_RATE+112];	// there can be at most 112 bytes left over from previous shake call
#endif
	uint16_t temp_ar[SABER_N];

  int i,j,k;

  uint64_t s[25];
  
  uint16_t pol_part_start_index, num_8coeff, num_8coeff_final, left_over_bytes, total_bytes;
  uint16_t row, column, num_polynomial;

  for (i = 0; i < 25; ++i)
    s[i] = 0;
  
  
  keccak_absorb(s, SHAKE128_RATE, seed, SABER_SEEDBYTES, 0x1F);

  pol_part_start_index=0; num_8coeff=0; left_over_bytes=0; total_bytes=0;
  num_polynomial=0;	

  while(num_polynomial!=9)
  {	

	keccak_squeezeblocks(shake_op_buf+left_over_bytes, 1, s, SHAKE128_RATE);

  	total_bytes = left_over_bytes + SHAKE128_RATE;

  	num_8coeff = total_bytes/13;

	if((num_8coeff*8+pol_part_start_index)>255)
		num_8coeff_final=32-pol_part_start_index/8;
	else 
		num_8coeff_final=num_8coeff;

	
  	byte_bank2pol_part(shake_op_buf, temp_ar, pol_part_start_index, num_8coeff_final);

  	left_over_bytes = total_bytes - num_8coeff_final*13;	


  	for(j=0; j<left_over_bytes; j++)	// bring the leftover in the begining of the buffer.
  		shake_op_buf[j] = shake_op_buf[num_8coeff_final*13+j];	

  	pol_part_start_index = pol_part_start_index + num_8coeff_final*8;	// this will be >256 when the polynomial is complete.

  	if(pol_part_start_index>255) 
  	{	 
		pol_part_start_index=0;

		if(num_polynomial>5) row=2;
		else if(num_polynomial>2) row=1;
        	else row = 0;
   
        	column = num_polynomial%3;
        	for(k=0;k<SABER_N;k++)
        	{
		   a[row].vec[column].coeffs[k] = temp_ar[k];
		}

		num_polynomial++;
	}
  }
}

void GenMatrix_poly(uint16_t temp_ar[], const unsigned char *seed, uint16_t poly_number) 
{
#if Saber_type == 3
  static unsigned char shake_op_buf[SHAKE128_RATE+144];	// there can be at most 112 bytes left over from previous shake call	
#else
  static unsigned char shake_op_buf[SHAKE128_RATE+112];	// there can be at most 112 bytes left over from previous shake call
#endif

  static int i,j;

  static uint64_t s[25];
  
  static uint16_t pol_part_start_index, num_8coeff, num_8coeff_final, left_over_bytes, total_bytes;
  static uint16_t poly_complete;


	// Init state when poly_number=0;

	if(poly_number==0)
	{
		for (i = 0; i < 25; ++i)
    		s[i] = 0;
  
  		keccak_absorb(s, SHAKE128_RATE, seed, SABER_SEEDBYTES, 0x1F);

  		pol_part_start_index=0; num_8coeff=0; left_over_bytes=0; total_bytes=0; 
	}


  poly_complete=0;

  while(poly_complete!=1)
  {	

	keccak_squeezeblocks(shake_op_buf+left_over_bytes, 1, s, SHAKE128_RATE);

  	total_bytes = left_over_bytes + SHAKE128_RATE;

  	num_8coeff = total_bytes/13;

	if((num_8coeff*8+pol_part_start_index)>255)
		num_8coeff_final=32-pol_part_start_index/8;
	else 
		num_8coeff_final=num_8coeff;

	
  	byte_bank2pol_part(shake_op_buf, temp_ar, pol_part_start_index, num_8coeff_final);

  	left_over_bytes = total_bytes - num_8coeff_final*13;	


  	for(j=0; j<left_over_bytes; j++)	// bring the leftover in the begining of the buffer.
  		shake_op_buf[j] = shake_op_buf[num_8coeff_final*13+j];	

  	pol_part_start_index = pol_part_start_index + num_8coeff_final*8;	// this will be >256 when the polynomial is complete.

  	if(pol_part_start_index>255) 
  	{	 
		pol_part_start_index=0;
		poly_complete++;
	}
  }

}

void indcpa_kem_keypair(unsigned char *pk, unsigned char *sk)
{
	int32_t i,j;
	uint16_t skpv[SABER_K][SABER_N];
	unsigned char noiseseed[SABER_COINBYTES];
	uint16_t res[SABER_K][SABER_N];

#if MUL_TYPE == TC_TC
	uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16];
#elif MUL_TYPE == TC_KARA
	uint16_t bw_ar[SABER_K][7][9][N_SB_16];
#endif

	randombytes(&pk[SABER_POLYVECCOMPRESSEDBYTES], SABER_SEEDBYTES);
	shake128(&pk[SABER_POLYVECCOMPRESSEDBYTES], SABER_SEEDBYTES, &pk[SABER_POLYVECCOMPRESSEDBYTES], SABER_SEEDBYTES); // for not revealing system RNG state
	randombytes(noiseseed, SABER_COINBYTES);

	GenSecret(skpv,noiseseed);//generate secret from constant-time binomial distribution

//------------------------do the matrix vector multiplication and rounding------------
	for(i=0;i<SABER_K;i++){
		for(j=0;j<SABER_N;j++){
			res[i][j]=0;
		}
	}

	//pre-computation B
	#if MUL_TYPE == TC_TC
		for(i=0;i<SABER_K;i++)
			evaluation_single((const uint16_t *)skpv[i], bw_ar[i]);
	#elif MUL_TYPE == TC_KARA
		for(i=0;i<SABER_K;i++)
			evaluation_single_kara((const uint16_t *)skpv[i], bw_ar[i]);
	#endif

	#if MUL_TYPE == TC_TC
		MatrixVectorMul(a,bw_ar,res,SABER_Q-1,1);
	#elif MUL_TYPE == TC_KARA
		// MatrixVectorMul(a,bw_ar,skpv,res,SABER_Q-1,1);
		MatrixVectorMul_keypair(&pk[SABER_POLYVECCOMPRESSEDBYTES],bw_ar,skpv,res);
	#endif
	
	//-----now rounding
	for(i=0;i<SABER_K;i++){ //shift right 3 bits
		for(j=0;j<SABER_N;j++){
			res[i][j]=res[i][j] + h1;
			res[i][j]=(res[i][j]>>(SABER_EQ-SABER_EP));
		}
	}
	//------------------unload and pack sk=3 x (256 coefficients of 14 bits)-------
	POLVECq2BS(sk, skpv);
	//------------------unload and pack pk=256 bits seed and 3 x (256 coefficients of 11 bits)-------
	POLVECp2BS(pk, res); // load the public-key coefficients
}


void indcpa_kem_enc(unsigned char *message_received, unsigned char *noiseseed, const unsigned char *pk, unsigned char *ciphertext)
{ 
	uint32_t i,j;
	uint16_t skpv1[SABER_K][SABER_N];
	uint16_t message_bit;
	uint16_t vprime[SABER_N];

	#if MUL_TYPE == TC_TC
		uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16];
	#elif MUL_TYPE == TC_KARA
		uint16_t bw_ar[SABER_K][7][9][N_SB_16];
	#endif

	GenSecret(skpv1,noiseseed);//generate secret from constant-time binomial distribution

	//-----------------matrix-vector multiplication and rounding
	//pre-computation B
	#if MUL_TYPE == TC_TC
		for(i=0;i<SABER_K;i++)
			evaluation_single((const uint16_t *)skpv1[i], bw_ar[i]);
	#elif MUL_TYPE == TC_KARA
		for(i=0;i<SABER_K;i++)
			evaluation_single_kara((const uint16_t *)skpv1[i], bw_ar[i]);

	#endif

	#if MUL_TYPE == TC_TC
		MatrixVectorMul(a, bw_ar,res,SABER_Q-1,0);
	#elif MUL_TYPE == TC_KARA
		// MatrixVectorMul(a, bw_ar, skpv1,res,SABER_Q-1,0);
		MatrixVectorMul_encryption(&pk[SABER_POLYVECCOMPRESSEDBYTES], bw_ar, skpv1, ciphertext);
	#endif
//********************client matrix-vector multiplication ends************************************
	//------now calculate the v'
	for(i=0;i<SABER_N;i++)
		vprime[i]=0;

	// vector-vector scalar multiplication with mod p
	#if MUL_TYPE == TC_TC	
		//InnerProd(pkcl,skpv1,(SABER_P-1),vprime);
		InnerProd(pkcl,bw_ar,(SABER_P-1),vprime);
	#elif MUL_TYPE == TC_KARA
		// InnerProd(pkcl,bw_ar,skpv1,(SABER_P-1),vprime);
		VectorMul(pk, bw_ar, skpv1, vprime);
	#endif

	for(j=0; j<SABER_KEYBYTES; j++) {
		for(i=0; i<8; i++) {
			message_bit = ((message_received[j]>>i) & 0x01);
			message_bit = (message_bit<<9);
			vprime[j*8+i]=vprime[j*8+i]- message_bit;
		}
	}

	for(i=0;i<SABER_N;i++) {
		vprime[i]=(vprime[i]+h1)>>(SABER_EP-SABER_ET);
	}

	#if Saber_type == 1
		SABER_pack_3bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#elif Saber_type == 2
		SABER_pack_4bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#elif Saber_type == 3
		SABER_pack_6bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#endif
}


void indcpa_kem_dec(const unsigned char *sk, const unsigned char *ciphertext, unsigned char message_dec[])
{

	uint32_t i,j;
	uint16_t sksv[SABER_K][SABER_N]; //secret key of the server
	uint16_t v[SABER_N];

	BS2POLVECq(sk, sksv); //sksv is the secret-key

	#if Saber_type == 1
		SABER_un_pack3bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], v);
	#elif Saber_type == 2
		SABER_un_pack4bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], v);
	#elif Saber_type == 3
		SABER_un_pack6bit(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], v);
	#endif

	for (i = 0; i < SABER_N; ++i) {
		v[i] = h2 - (v[i] << (SABER_EP-SABER_ET));
	}

	#if MUL_TYPE == TC_TC
		uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16];
		for(i=0;i<SABER_K;i++)
			evaluation_single((const uint16_t *)sksv[i], bw_ar[i]);
	#elif MUL_TYPE == TC_KARA
		uint16_t bw_ar[SABER_K][7][9][N_SB_16];
		for(i=0;i<SABER_K;i++)
			evaluation_single_kara((const uint16_t *)sksv[i], bw_ar[i]);
	#endif
	#if MUL_TYPE == TC_TC
		InnerProd(pksv, bw_ar,(SABER_P-1),v);
	#elif MUL_TYPE == TC_KARA
		// InnerProd(pksv, bw_ar, sksv,(SABER_P-1),v);
		VectorMul(ciphertext, bw_ar, sksv, v);
	#endif

	for (i = 0; i < SABER_N; ++i) {
		v[i] = (v[i] & (SABER_P-1)) >> (SABER_EP-1);
	}

	POL2MSG(v, message_dec);
}


void POL2MSG(uint16_t *message_dec_unpacked, unsigned char *message_dec){

	int32_t i,j;

	for(j=0; j<SABER_KEYBYTES; j++)
	{
		message_dec[j] = 0;
		for(i=0; i<8; i++)
		message_dec[j] = message_dec[j] | (message_dec_unpacked[j*8 + i] <<i);
	} 

}

#if MUL_TYPE == TC_TC

	void MatrixVectorMul(polyvec *a, uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16], uint16_t res[SABER_K][SABER_N], uint16_t mod, int16_t transpose){

		uint16_t acc[SABER_N]; 
		int32_t i,j,k,l;

		uint16_t result_final[2*SABER_N];
	//----------------------initialization and precomputation of B--------------------------

		uint32_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];
	//----------------------initialization and precomputation of B ends---------------------
		if(transpose==1){
			for(i=0;i<SABER_K;i++){
				//----------------------make it the result holder zero--------------------------
				for(l=0;l<7;l++){
					for(j=0;j<NUM_POLY_MID;j++){
						for(k=0;k<N_SB_16_RES;k++){
							w_ar[l][j][k]=0;
						}
					}
				}
				for(k=0;k<2*SABER_N;k++){
						result_final[k]=0;
				}
				//----------------------make it the result holder zero ends---------------------

				for(j=0;j<SABER_K;j++){
					//------here goes the eval everytime
					TC_evaluation_64_unrolled((const uint16_t *)&a[j].vec[i], bw_ar[j], w_ar);

					if(j==SABER_K-1){
						TC_interpol_64_unrolled(w_ar,result_final);
					//----------polynomial reduction----------------
						for(k=SABER_N;k<2*SABER_N;k++){
							res[i][k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
						}
					//----------polynomial reduction ends-----------
					
					}			
				}
			}
		}
		else{
			for(i=0;i<SABER_K;i++){
				//----------------------make it the result holder zero--------------------------
				for(l=0;l<7;l++){
					for(j=0;j<NUM_POLY_MID;j++){
						for(k=0;k<N_SB_16_RES;k++){
							w_ar[l][j][k]=0;
						}
					}
				}
				for(k=0;k<2*SABER_N;k++){
						result_final[k]=0;
				}
				//----------------------make it the result holder zero ends---------------------

				for(j=0;j<SABER_K;j++){
					//------here goes the eval everytime
					TC_evaluation_64_unrolled((const uint16_t *)&a[i].vec[j], bw_ar[j], w_ar);

					if(j==SABER_K-1){
						TC_interpol_64_unrolled(w_ar,result_final);
					//----------polynomial reduction----------------
						for(k=SABER_N;k<2*SABER_N;k++){
							res[i][k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
						}
					//----------polynomial reduction ends-----------
					
					}			
				}
			}
		}
	}


	void InnerProd(uint16_t pkcl[SABER_K][SABER_N],	uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16], uint16_t mod,uint16_t res[SABER_N]){


		uint16_t i,j,k;
		uint16_t acc[SABER_N]; 
		uint16_t result_final[2*SABER_N];

	//----------------------initialization and precomputation of B--------------------------

		uint32_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

	//----------------------initialization and precomputation of B ends---------------------


				//----------------------make it the result holder zero--------------------------
			for(i=0;i<7;i++){
				for(j=0;j<NUM_POLY_MID;j++){
					for(k=0;k<N_SB_16_RES;k++){
						w_ar[i][j][k]=0;
					}
				}
			}
			for(k=0;k<2*SABER_N;k++){
					result_final[k]=0;
			}
			//----------------------make it the result holder zero ends---------------------
			for(j=0;j<SABER_K;j++){
				//------here goes the eval everytime
				TC_evaluation_64_unrolled((const uint16_t *)pkcl[j], bw_ar[j], w_ar);
				if(j==SABER_K-1){
					TC_interpol_64_unrolled(w_ar,result_final);
				//----------polynomial reduction----------------
					for(k=SABER_N;k<2*SABER_N;k++){
						res[k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
					}
				//----------polynomial reduction ends-----------
				
				}			
			}
	}

#elif MUL_TYPE == TC_KARA


	void MatrixVectorMul(polyvec *a, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t res[SABER_K][SABER_N], uint16_t mod, int16_t transpose){

		uint16_t acc[SABER_N]; 
		int32_t i,j,k,l;

		uint16_t result_final[2*SABER_N];
	//----------------------initialization and precomputation of B--------------------------

		uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];
	//----------------------initialization and precomputation of B ends---------------------
		if(transpose==1){
			for(i=0;i<SABER_K;i++){
				//----------------------make it the result holder zero--------------------------
				for(l=0;l<7;l++){
					for(j=0;j<NUM_POLY_MID;j++){
						for(k=0;k<N_SB_16_RES;k++){
							w_ar[l][j][k]=0;
						}
					}
				}
				for(k=0;k<2*SABER_N;k++){
						result_final[k]=0;
				}
				//----------------------make it the result holder zero ends---------------------

				for(j=0;j<SABER_K;j++){
					//------here goes the eval everytime
					//TC_evaluation_64_unrolled((const uint16_t *)&a[j].vec[i], bw_ar[j], w_ar);
					// TC_evaluation_unrolled_kara((const uint16_t *)&a[j].vec[i], (const uint16_t *)skpv[j], bw_ar[j], w_ar);
					TC_evaluation_unrolled_kara((const uint16_t *)&a[j].vec[i], bw_ar[j], w_ar);

					if(j==SABER_K-1){
						//TC_interpol_64_unrolled(w_ar,result_final);
						// TC_interpol1_kara(w_ar, result_final);
						TC_interpol1_kara(w_ar, res[i]);
					//----------polynomial reduction----------------
						// for(k=SABER_N;k<2*SABER_N;k++){
						// 	res[i][k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
						// }
					//----------polynomial reduction ends-----------
					
					}			
				}
			}
		}
		else{
			for(i=0;i<SABER_K;i++){
				//----------------------make it the result holder zero--------------------------
				for(l=0;l<7;l++){
					for(j=0;j<NUM_POLY_MID;j++){
						for(k=0;k<N_SB_16_RES;k++){
							w_ar[l][j][k]=0;
						}
					}
				}
				for(k=0;k<2*SABER_N;k++){
						result_final[k]=0;
				}
				//----------------------make it the result holder zero ends---------------------

				for(j=0;j<SABER_K;j++){
					//------here goes the eval everytime
					//TC_evaluation_64_unrolled((const uint16_t *)&a[i].vec[j], bw_ar[j], w_ar);
					// TC_evaluation_unrolled_kara((const uint16_t *)&a[i].vec[j], (const uint16_t *)skpv[j], bw_ar[j], w_ar);
					TC_evaluation_unrolled_kara((const uint16_t *)&a[i].vec[j], bw_ar[j], w_ar);

					if(j==SABER_K-1){
						//TC_interpol_64_unrolled(w_ar,result_final);
						// TC_interpol1_kara(w_ar, result_final);
						TC_interpol1_kara(w_ar, res[i]);
					//----------polynomial reduction----------------
						// for(k=SABER_N;k<2*SABER_N;k++){
						// 	res[i][k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
						// }
					//----------polynomial reduction ends-----------
					
					}			
				}
			}
		}
	}

		void InnerProd(uint16_t pkcl[SABER_K][SABER_N],	uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t mod,uint16_t res[SABER_N]){


			uint16_t i,j,k;
			uint16_t acc[SABER_N]; 
			uint16_t result_final[2*SABER_N];

		//----------------------initialization and precomputation of B--------------------------

			uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

		//----------------------initialization and precomputation of B ends---------------------


					//----------------------make it the result holder zero--------------------------
				for(i=0;i<7;i++){
					for(j=0;j<NUM_POLY_MID;j++){
						for(k=0;k<N_SB_16_RES;k++){
							w_ar[i][j][k]=0;
						}
					}
				}
				for(k=0;k<2*SABER_N;k++){
						result_final[k]=0;
				}
				//----------------------make it the result holder zero ends---------------------
				for(j=0;j<SABER_K;j++){
					//------here goes the eval everytime
					//TC_evaluation_64_unrolled((const uint16_t *)pkcl[j], bw_ar[j], w_ar);
					// TC_evaluation_unrolled_kara((const uint16_t *)pkcl[j], (const uint16_t *)skpv[j], bw_ar[j], w_ar);
					TC_evaluation_unrolled_kara((const uint16_t *)pkcl[j], bw_ar[j], w_ar);
					if(j==SABER_K-1){
						//TC_interpol_64_unrolled(w_ar,result_final);
						// TC_interpol1_kara(w_ar, result_final);
						TC_interpol1_kara(w_ar, res);
					//----------polynomial reduction----------------
						// for(k=SABER_N;k<2*SABER_N;k++){
						// 	res[k-SABER_N]=(result_final[k-SABER_N]-result_final[k])&(mod);
						// }
					//----------polynomial reduction ends-----------
				
					}			
				}
		}


#endif

void MatrixVectorMul_keypair(const unsigned char *seed, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], uint16_t res[SABER_K][SABER_N])
{
	int32_t i,j,k,l;
	uint16_t temp_ar[SABER_N];

	uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

	polyvec a[SABER_K];
	GenMatrix(a, seed);

	for(i=0;i<SABER_K;i++){
		//----------------------make it the result holder zero--------------------------
		for(l=0;l<7;l++){
			for(j=0;j<NUM_POLY_MID;j++){
				for(k=0;k<N_SB_16_RES;k++){
					w_ar[l][j][k]=0;
				}
			}
		}
		for(j=0;j<SABER_K;j++){
			// GenMatrix_poly(temp_ar, seed, i+j);			
			//------here goes the eval everytime
			TC_evaluation_unrolled_kara((const uint16_t *)&a[j].vec[i], bw_ar[j], w_ar);
			// TC_evaluation_unrolled_kara((const uint16_t *)temp_ar, bw_ar[j], w_ar);
			if(j==SABER_K-1){
				TC_interpol1_kara(w_ar, res[i]);
			}
		}
	}
}

void MatrixVectorMul_encryption(const unsigned char *seed, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], unsigned char *ciphertext)
{
	uint16_t acc[SABER_N]; 
	int32_t i,j,k,l;
	uint16_t res[SABER_N];

	uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

	for(i=0;i<SABER_K;i++) {
		//----------------------make it the result holder zero--------------------------
		memset(w_ar, 0, 2*7*NUM_POLY_MID*N_SB_16_RES);
		// for(l=0;l<7;l++){
		// 	for(j=0;j<NUM_POLY_MID;j++){
		// 		for(k=0;k<N_SB_16_RES;k++){
		// 			w_ar[l][j][k]=0;
		// 		}
		// 	}
		// }
		for(j=0;j<SABER_N;j++) {
			res[j]=0;
		}
		for(j=0;j<SABER_K;j++) {
			GenMatrix_poly(acc, seed, i+j);
			// toom_cook_4way_mem(acc, skpv[j], res);
			//------here goes the eval everytime
			// TC_evaluation_unrolled_kara((const uint16_t *)&a[i].vec[j], bw_ar[j], w_ar);
			TC_evaluation_unrolled_kara((const uint16_t *)acc, bw_ar[j], w_ar);
			if(j==SABER_K-1){
				TC_interpol1_kara(w_ar, res);
			}
		}		
		// Now one polynomial of the output vector is ready.
		// Rounding: perform bit manipulation before packing into ciphertext 
		for(k=0;k<SABER_N;k++) {
			res[k]=res[k]+4;
			res[k]=(res[k]>>3);
		}
		POLp2BS(ciphertext, res, i);
	}
}

void VectorMul(const unsigned char *byte_array, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N],uint16_t res[SABER_N])
{
	uint32_t i,j,k;
	uint16_t pkcl[SABER_N];
	uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

	//----------------------make it the result holder zero--------------------------
	memset(w_ar, 0, 2*7*NUM_POLY_MID*N_SB_16_RES);
	// for(i=0;i<7;i++){
	// 	for(j=0;j<NUM_POLY_MID;j++){
	// 		for(k=0;k<N_SB_16_RES;k++){
	// 			w_ar[i][j][k]=0;
	// 		}
	// 	}
	// }
	//----------------------make it the result holder zero ends---------------------

	// vector-vector scalar multiplication with mod p
	for(j=0;j<SABER_K;j++){
		BS2POLp(j, byte_array, pkcl);
		// toom_cook_4way_mem(pkcl, skpv[j], res);
		//------here goes the eval everytime
		TC_evaluation_unrolled_kara((const uint16_t *)pkcl, bw_ar[j], w_ar);
		if(j==SABER_K-1){
			TC_interpol1_kara(w_ar, res);
		}
	}
}

unsigned char MatrixVectorMul_encryption_cmp(const unsigned char *seed, uint16_t bw_ar[SABER_K][7][9][N_SB_16], uint16_t skpv[SABER_K][SABER_N], unsigned char *ciphertext)
{
	unsigned char fail = 0;
	uint16_t acc[SABER_N]; 
	int32_t i,j,k;
	uint16_t res[SABER_N];

	uint16_t w_ar[7][NUM_POLY_MID][N_SB_16_RES];

	for(i=0;i<SABER_K;i++) {
		memset(w_ar, 0, 2*7*NUM_POLY_MID*N_SB_16_RES);
		for(j=0;j<SABER_N;j++) {
			res[j]=0;
		}
		for(j=0;j<SABER_K;j++) {
			GenMatrix_poly(acc, seed, i+j);
			// toom_cook_4way_mem(acc, skpv[j], res);
			//------here goes the eval everytime
			// TC_evaluation_unrolled_kara((const uint16_t *)&a[i].vec[j], bw_ar[j], w_ar);
			TC_evaluation_unrolled_kara((const uint16_t *)acc, bw_ar[j], w_ar);
			if(j==SABER_K-1){
				TC_interpol1_kara(w_ar, res);
			}
		}
		// Now one polynomial of the output vector is ready.
		// Rounding: perform bit manipulation before packing into ciphertext 
		for(k=0;k<SABER_N;k++) {
			res[k]=res[k]+4;
			res[k]=(res[k]>>3);
		}		
		fail |= POLp2BS_cmp(ciphertext, res, i);
	}
	return fail;
}

unsigned char indcpa_kem_enc_cmp(unsigned char *message_received, unsigned char *noiseseed, const unsigned char *pk, unsigned char *ciphertext)
{
	uint32_t fail = 0;

	uint32_t i,j;
	uint16_t skpv1[SABER_K][SABER_N];
	uint16_t message_bit;
	uint16_t vprime[SABER_N];

	#if MUL_TYPE == TC_TC
		uint32_t bw_ar[SABER_K][7][NUM_POLY_MID][N_SB_16];
	#elif MUL_TYPE == TC_KARA
		uint16_t bw_ar[SABER_K][7][9][N_SB_16];
	#endif

	GenSecret(skpv1,noiseseed);//generate secret from constant-time binomial distribution

	//-----------------matrix-vector multiplication and rounding
	//pre-computation B
	#if MUL_TYPE == TC_TC
		for(i=0;i<SABER_K;i++)
			evaluation_single((const uint16_t *)skpv1[i], bw_ar[i]);
	#elif MUL_TYPE == TC_KARA
		for(i=0;i<SABER_K;i++)
			evaluation_single_kara((const uint16_t *)skpv1[i], bw_ar[i]);

	#endif

	#if MUL_TYPE == TC_TC
		MatrixVectorMul(a, bw_ar,res,SABER_Q-1,0);
	#elif MUL_TYPE == TC_KARA
		// MatrixVectorMul(a, bw_ar, skpv1,res,SABER_Q-1,0);
		fail |= MatrixVectorMul_encryption_cmp(&pk[SABER_POLYVECCOMPRESSEDBYTES], bw_ar, skpv1, ciphertext);
	#endif
//********************client matrix-vector multiplication ends************************************

	for(i=0;i<SABER_N;i++)
		vprime[i]=0;

	// vector-vector scalar multiplication with mod p
	#if MUL_TYPE == TC_TC	
		//InnerProd(pkcl,skpv1,(SABER_P-1),vprime);
		InnerProd(pkcl,bw_ar,(SABER_P-1),vprime);
	#elif MUL_TYPE == TC_KARA
		// InnerProd(pkcl,bw_ar,skpv1,(SABER_P-1),vprime);
		VectorMul(pk, bw_ar, skpv1, vprime);
	#endif

	for(j=0; j<SABER_KEYBYTES; j++) {
		for(i=0; i<8; i++) {
			message_bit = ((message_received[j]>>i) & 0x01);
			message_bit = (message_bit<<9);
			vprime[j*8+i]=vprime[j*8+i]- message_bit;
		}
	}

	for(i=0;i<SABER_N;i++) {
		vprime[i]=(vprime[i]+h1)>>(SABER_EP-SABER_ET);
	}

	#if Saber_type == 1
		fail |= SABER_pack_3bit_cmp(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#elif Saber_type == 2
		fail |= SABER_pack_4bit_cmp(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#elif Saber_type == 3
		fail |= SABER_pack_6bit_cmp(&ciphertext[SABER_POLYVECCOMPRESSEDBYTES], vprime);
	#endif

	fail = (~fail + 1);
	fail >>= 31;

	return (unsigned char)fail;
}
