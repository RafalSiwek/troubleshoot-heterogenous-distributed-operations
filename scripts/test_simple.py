import os

import torch
import torch.distributed as dist

LOCAL_RANK = int(os.environ["OMPI_COMM_WORLD_LOCAL_RANK"])
WORLD_SIZE = int(os.environ["OMPI_COMM_WORLD_SIZE"])
WORLD_RANK = int(os.environ["OMPI_COMM_WORLD_RANK"])


def run(backend):
    tensor = torch.zeros(1)

    # Put tensor on a GPU device
    device = torch.device("cuda:{}".format(LOCAL_RANK))
    tensor = tensor.to(device)

    if WORLD_RANK == 0:
        for rank_recv in range(1, WORLD_SIZE):
            dist.send(tensor=tensor, dst=rank_recv)
            print("worker_{} sent data to Rank {}\n".format(0, rank_recv))
    else:
        dist.recv(tensor=tensor, src=0)
        print("worker_{} has received data from rank {}\n".format(WORLD_RANK, 0))


def init_processes(backend):
    dist.init_process_group(backend, rank=WORLD_RANK, world_size=WORLD_SIZE)
    run(backend)


if __name__ == "__main__":
    init_processes(backend="mpi")
