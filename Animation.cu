#include <cstdint>
#include <iostream>

#include "Animation.h"
#include "GPUFunctions.h"

const uint32_t THREADSPERBLOCK = 1024;
const float forceOfGravity = 500;
const uint32_t AREATOCHECK = 50;
const float maxSpeed = 25;

__global__ void randomizeValues(float * pPosX, float * pPosY, float * pVelX, float * pVelY, uint32_t particleCount, uint32_t width, uint32_t height, uint64_t * rand, uint32_t * color) {
	uint32_t index = blockIdx.x *blockDim.x + threadIdx.x;

	if(index < particleCount) {
		
	}
}

__global__ void nextFrameGPU(float * pPosX, float * pPosY, float * pVelX, float * pVelY, uint32_t particleCount, uint32_t width, uint32_t height, int64_t * occupied, uint32_t * color) {
	uint32_t index = blockIdx.x *blockDim.x + threadIdx.x;

	if(index < particleCount) {
		
	}
}

__global__ void createRender(uint32_t * image, float * pPosX, float * pPosY, uint32_t particleCount, uint32_t width, uint32_t height, uint32_t * color) {
	uint32_t index = blockIdx.x *blockDim.x + threadIdx.x;

	if(index < particleCount) {

	}
}

Animation::Animation(uint32_t widthIn, uint32_t heightIn, uint32_t particlesIn) {
	width = widthIn;
	height = heightIn;
	particleCount = particlesIn;
	// TODO: test if using passed in variables is better than class variables
	particlePositionsX = (float *) gpuMemAlloc(particleCount * sizeof(float));
	particlePositionsY = (float *) gpuMemAlloc(particleCount * sizeof(float));
	particleVelocitiesX = (float *) gpuMemAlloc(particleCount * sizeof(float));
	particleVelocitiesY = (float *) gpuMemAlloc(particleCount * sizeof(float));
	imageSize = width * height * sizeof(uint32_t);
	d_image = (uint32_t *) gpuMemAlloc(imageSize);
	image = (uint32_t *) malloc(imageSize);
	blockCountGPU = (particleCount + THREADSPERBLOCK - 1)/THREADSPERBLOCK;
	init();
}

void Animation::init() {
	randomizeValues <<< blockCountGPU, THREADSPERBLOCK >>> (particlePositionsX, particlePositionsY, particleVelocitiesX,  particleVelocitiesY, particleCount, width, height, d_rand, color);
}

void Animation::nextFrame() {
	cudaMemset(d_image, 0x00000000, imageSize);
	nextFrameGPU <<< blockCountGPU, THREADSPERBLOCK >>> (particlePositionsX, particlePositionsY, particleVelocitiesX, particleVelocitiesY, particleCount, width, height, d_occupied, color);
	cudaMemset(d_occupied, -1, width * height * sizeof(int64_t));
	createRender <<< blockCountGPU, THREADSPERBLOCK >>> (d_image, particlePositionsX, particlePositionsY, particleCount, width, height, color);
}

void Animation::exit() {
	cudaFree(d_image);
	cudaFree(particlePositionsX);
	cudaFree(particlePositionsY);
	cudaFree(particleVelocitiesX);
	cudaFree(particleVelocitiesY);
}

void * Animation::getImage() {
	cudaMemcpy(image, d_image, imageSize, cudaMemcpyDeviceToHost);
	return image;
}