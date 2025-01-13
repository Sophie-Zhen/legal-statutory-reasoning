# Baseline Experiments on SARA Dataset

We reproduced the experiments in [Can GPT-3 Perform Statutory Reasoning?](https://github.com/BlairStanek/gpt-statutes/tree/main). The original authors conducted their experiments using **GPT-3**, and we reproduced them using **gpt-4o-2024-08-06**. The fixed version ensures future reproducibility. Some modifications were made to the original code to adapt it to our setup.

## Results and Scripts

### 1. Statutory Reasoning Without Numerical Calculation
- **Results Folder**: `/results_nonum`
- **Script**: `/call_gpt_with_sara.py`
- This folder contains the results of statutory reasoning experiments on the [SARA](https://huggingface.co/datasets/jhu-clsp/SARA) dataset **without numerical calculation**.

### 2. Statutory Reasoning With Numerical Calculation
- **Results Folder**: `/results_num`
- **Script**: `/call_gpt_with_sara_numerical.py`
- This folder contains the results of statutory reasoning experiments on the [SARA](https://huggingface.co/datasets/jhu-clsp/SARA) dataset **with numerical calculation**.

## Objective
The comparison will be made between **gpt-4o-2024-08-06** and the original **GPT-3** results. This setup also serves as preparation for our next-stage experiments.