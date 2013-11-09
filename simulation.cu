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
};

typedef struct route * Route;


__global__ void randomSimulation(Route rdata, int *rewards)
{
    const int customerSize = Vrp_GetNumberOfCustomers();
    int candidates[customerSize], candidateSize;

    // thread数がcustomerより多いことを想定
    int customer = threadIdx.x;

    while (!Route_AllCustomersIsVisited(rdata) && Vrp_VehicleIsInBound())
    {
        // 訪問していない顧客を調べる
        if (customer < customerSize)
        {
            if (isVisit(rdata, customer))
            {
                // candidates配列にシーケンシャルに代入する
                // candidateSizeをインクリメントする
            }
        }

        __syncthreads();

        // 一つのthreadだけがすればよい
        if (threadIdx.x == 0)
        {
            if (candidateSize != 0)
            {
                // rand()関数をMTGP(?)にする必要がある
                int elected = rand() % candidateSize;
                Route_Update(rdata, rdata->vehicleNumber);
            }
            else
            {
                Route_SetVehicleNumber(rdata, rdata->vehicleNumber+1);
            }
        }
    }

    if (threadIdx.x == 0)
    {
        if (Route_AllCustomersIsVisited(rdata))
            rewards =  Route_CalculateCost(rdata);
        else
            rewards = 100000;
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
