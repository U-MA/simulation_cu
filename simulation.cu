#include "cuda.h"

#include <iostream>
using namespace std;


struct route
{
    int routeSize;
    int *route;
    int vehicleNumber;
    int *visitCustomer; // 訪れた顧客の数
    int *quantity;
	__device__ bool isVisit(const int customer)
	{
		for (int i=0; i < route_size; i++)
		{
			if (route[i] == customer) return true;
		}
		return false;
	}
	__device__ bool isVisitedAll(const int customer_size)
	{
		for (int i=1; i < customer_size; i++)
		{
			for (int j=0; j < routeSize; j++)
			{
				if (route[j] == i) break;
			}
			if (j == routeSize) return false;
		}
		return true;
	}
	__device__ void update(int move)
	{
		if (move == 0)
		{
			vehicleNumber++;
			return;
		}

		int offset = // TODO;
		route[offset] = move;
		VisitedCustomer[vehicleNumber]++;
		quantity[vehicleNumber] += //TODO: capacityの追加
	}
	__device__ void vehicleChange()
	{
		vehicleNumber++;
	}
	__device__ unsigned int calculateCost()
	{
		return 0; // TODO
	}
};

typedef struct route * Route;


/* TODO: Vrpモジュールをどう扱うか
 *       2013.11.13現在 Vrpモジュールはシングルインスタンスモジュールとして
 *                      vrp.cpp内にファイルスコープに入れている
 *                      GPUコードでは扱いにくいので公開するべきか？
 *                      それともvrp.cppをvrp.cuに変更し、すべての関数に
 *                      __device__ __host__をつけるべきか？
 */
__global__ void randomSimulation(Route rdata, unsigned int *rewards)
{
    const int customerSize = Vrp_GetNumberOfCustomers();
    int candidates[customerSize], candidateSize;

    // thread数がcustomerより多いことを想定
    int customer = threadIdx.x;

    while (!rdata->isVisitedAll(customerSize) && Vrp_VehicleIsInBound())
    {
        // 訪問していない顧客を調べる
        if (customer < customerSize)
        {
            if (rdata->isVisit(customer))
            {
                // candidates配列にシーケンシャルに代入する
                // candidateSizeをインクリメントする
            }
        }

        __syncthreads();

        // rdataに顧客を追加するor車体の変更
		//一つのthreadだけがすればよい
        if (threadIdx.x == 0)
        {
            if (candidateSize != 0)
            {
                // rand()関数をrandom123にする必要がある
                int elected = rand() % candidateSize;
                rdata->update(elected);
            }
            else
            {
                rdata->vehicleChange();
            }
        }
    }

    if (threadIdx.x == 0)
    {
        if (rdata->isVisitedAll(customerSize))
            *rewards =  Route_CalculateCost(rdata);
        else
            *rewards = 100000;
    }
}


// 要素数nの配列aの中から最小値を求める
__global__ reduction(int *a, int n, int *b)
{
}


int main(int argc, char **argv)
{
    Vrp_Create("Vrp-All/E/E-n13-k4.vrp");
    Route rdata = Route_Create();
    Route dev_rdata;
    int reward, *dev_reward, *dev_rewards;

    const int blocks = 1024;
    const int threads = Vrp_GetNumberOfCustomers();

    cudaMalloc((void**)&dev_rdata, sizeof(struct route));
    cudaMalloc((void**)&dev_rewards, sizeof(int) * blocks);
    cudaMalloc((void**)&dev_reward, sizeof(int));

    cudaMemcpy(dev_rdata, rdata, sizeof(struct route), cudaMemcpyHostToDevice);

    randomSimulation<<<1024,threads>>>(dev_route, dev_rewards);
    reduction<<<1,blocks>>>(dev_rewards, blocks, dev_reward);

    cudaMemcpy(reward, dev_reward, sizeof(int), cudaMemcpyDeviceToHost);

    cout << "reward: " << reward << endl;

    return 0;
}
