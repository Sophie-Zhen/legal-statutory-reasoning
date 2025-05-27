#!/usr/bin/env python3
"""
Fine-tune Flan-T5-Small to map statute text → Prolog rules.
"""

import json
from pathlib import Path
from datasets import load_dataset, DatasetDict


from datasets import load_dataset, DatasetDict
from transformers import (
    AutoTokenizer, 
    AutoModelForSeq2SeqLM, 
    DataCollatorForSeq2Seq,
    TrainingArguments, 
    Trainer
)

def main():
    # 1. Load parallel data (default split named "train")
    raw_ds = load_dataset("json", data_files="data/sara_parallel.jsonl")
    ds = raw_ds["train"]

    
    # 2. Split into train/val (80/20)
    split = ds.train_test_split(test_size=0.2, seed=42)
    ds = DatasetDict({"train": split["train"], "validation": split["test"]})

    
    # 3. Tokenizer & model
    model_name = "google/flan-t5-small"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model     = AutoModelForSeq2SeqLM.from_pretrained(model_name)
    
    # 4. Preprocessing
    max_in  = 512
    max_out = 256
    def preprocess(batch):
        inputs  = tokenizer(batch["statute"],  max_length=max_in,  truncation=True, padding="max_length")
        targets = tokenizer(batch["logic"],    max_length=max_out, truncation=True, padding="max_length")
        return {
            "input_ids":     inputs.input_ids,
            "attention_mask":inputs.attention_mask,
            "labels":        targets.input_ids
        }
    ds = ds.map(preprocess, batched=True, remove_columns=["statute", "logic"])
    
    # 5. Data collator
    data_collator = DataCollatorForSeq2Seq(tokenizer, model=model)
    
    # 6. Training arguments
    args = TrainingArguments(
        output_dir="models/t5_statute2logic",
        per_device_train_batch_size=4,
        per_device_eval_batch_size=4,
        num_train_epochs=3,
        learning_rate=1e-4,
        weight_decay=0.01,
        save_total_limit=2,
        push_to_hub=False,
        logging_dir="logs",
        logging_steps=10,
    )

    
    # 7. Trainer
    trainer = Trainer(
        model=model,
        args=args,
        train_dataset=ds["train"],
        eval_dataset=ds["validation"],
        tokenizer=tokenizer,
        data_collator=data_collator,
    )
    
    # 8. Train and save
    trainer.train()
    trainer.save_model("models/t5_statute2logic")
    tokenizer.save_pretrained("models/t5_statute2logic")
    print("Training complete. Model saved to models/t5_statute2logic.")

if __name__ == "__main__":
    main()
