# This calls GPT-* with the SARA questions answered by either Entailment or
# Contradiction (i.e., not dollar figures).
import json, sys, argparse
sys.path.append('/Users/sophie/Desktop/2025-mcm-llms-applied-in-law_context/src/gpt-statutes')
import utils
from utils import is_entail, is_contra, is_entail_or_contra, reformat_case, print_confusion_matrix

ENTAILMENT = "Entailment" # these ensure string typos don't throw off statistics
CONTRADICTION = "Contradiction"
UNCLEAR = "unclear"

def print_confusion_matrix(groundtruth_vs_response):
    print("                ", "      Response from model         ")
    print("                ", "  entail      contrad.   unclear ")
    print("Actual  entail  ",
          "  {:6d} ".format(groundtruth_vs_response[ENTAILMENT][ENTAILMENT]),
          "   {:6d} ".format(groundtruth_vs_response[ENTAILMENT][CONTRADICTION]),
          "   {:6d} ".format(groundtruth_vs_response[ENTAILMENT][UNCLEAR]))
    print("        contrad.",
          "  {:6d} ".format(groundtruth_vs_response[CONTRADICTION][ENTAILMENT]),
          "   {:6d} ".format(groundtruth_vs_response[CONTRADICTION][CONTRADICTION]),
          "   {:6d} ".format(groundtruth_vs_response[CONTRADICTION][UNCLEAR]))

parser = argparse.ArgumentParser(description='Call GPT with 4-shot dynamic prompts for SARA')
parser.add_argument('--letsthink', required=True, choices=["Yes", "no"],
                    help='Whether to add "Lets think step by step." per Kojima et al 2022')
parser.add_argument('--withstatute', required=True, choices=["Yes", "no"],
                    help='Whether to include the relevant statute at the top of the prompt')
parser.add_argument('--ptype', required=True, choices=["0shot", "4shot", "chainofthought"],
                    help='These are the basic types of prompting we handle')
parser.add_argument('--model', default="gpt-4o-2024-08-06",
                    help='name of the openai model to call')

args = parser.parse_args()

max_tokens = 1200  # works safely for most of our calls to GPT3

CoT_text = "" # if we are doing chain of thought reasoning, we should read in the hand-crafted chains now
if args.ptype == "chainofthought":
    if args.withstatute == "Yes":
        with open("sara-chain-of-thought-prompt.txt", "r") as fCOT:
            CoT_text = fCOT.read()
        max_tokens = 336 # most that can be accomodated with this prompt as is
    else:
        with open("sara-chain-of-thought-prompt-NOSTATUTES.txt", "r") as fCOT:
            CoT_text = fCOT.read()


# used to get the confusion matrix for dollar-figure-based entailment problems
dollar_groundtruth_vs_response = { ENTAILMENT: {ENTAILMENT:0, CONTRADICTION:0, "unclear":0},
                                  CONTRADICTION: {ENTAILMENT:0, CONTRADICTION:0, "unclear":0}}
nodollar_groundtruth_vs_response = { ENTAILMENT: {ENTAILMENT:0, CONTRADICTION:0, "unclear":0},
                                  CONTRADICTION: {ENTAILMENT:0, CONTRADICTION:0, "unclear":0}}

utils.add_comment("START " + __file__)

START_PROMPT = "We are going to be doing Entailment/Contradiction reasoning applying the statute below:\n\n"

suggested_filename = args.ptype + "_letsthink_" + args.letsthink + "_withstatute_" + args.withstatute + "_" + args.model + ".txt"

with open(suggested_filename, "w") as f:
    f.write("")
    f.close()

def log_to_file_and_print(file, message):# add logging instantly to a file and print it
    print(message)
    file.write(message + "\n")
    file.flush()

json_records = json.load(open('statutory-reasoning-gpt-prompts.json', 'r'))
for json_item in json_records:

    if not is_entail_or_contra(json_item["answer"]):
        continue # only handling non-number cases in this file; number cases are in call_gpt_with_sara_numerical.py

    has_dollar = ("$" in json_item['test case']) # separates out the numerical and non-numerical ones
    prompt = ""
    if args.ptype == "chainofthought":
        prompt += CoT_text
    else:
        if args.withstatute == "Yes":
            prompt += START_PROMPT
            prompt += json_item['statute'].replace("\n\n", "\n")  # removes double newlines
            prompt = prompt.strip() + "\n\n"

        if args.ptype == "4shot":
            prompt += reformat_case(json_item['case1'],     "Premise: ", "Hypothesis: ", "Answer: ",
                                    add_cite_before_section=(args.withstatute == "no")) + "\n\n"
            prompt += reformat_case(json_item['case2'],     "Premise: ", "Hypothesis: ", "Answer: ",
                                    add_cite_before_section=(args.withstatute == "no")) + "\n\n"
            prompt += reformat_case(json_item['case3'],     "Premise: ", "Hypothesis: ", "Answer: ",
                                    add_cite_before_section=(args.withstatute == "no")) + "\n\n"
            prompt += reformat_case(json_item['case4'],     "Premise: ", "Hypothesis: ", "Answer: ",
                                    add_cite_before_section=(args.withstatute == "no")) + "\n"
    prompt = prompt.strip() + "\n\n"

    # Now the one we want answered:
    prompt += reformat_case(json_item['test case'], "Premise: ", "Hypothesis: ", "Answer: ", True,
                            add_cite_before_section=(args.withstatute == "no"))
    if args.letsthink == "Yes":
        prompt += "Let's think step by step." # following Kojima et al. 2022

    prompt = prompt.strip() # GPT-* apparently does not like whitespace at the start or end of the prompt

    utils.add_comment("Doing case id=" + json_item["case id"])
    first_response = utils.call_gpt_withlogging(prompt, args.model, max_tokens=max_tokens)
    utils.add_comment("NOTE that correct response is " + json_item["answer"])

    stripped_response = first_response.lstrip() # note that there is a space at the start of what will be appended
    if not stripped_response[0].isspace():
        stripped_response = " " + stripped_response
    second_prompt = prompt + \
                    stripped_response + \
                    " Therefore, the answer (Entailment or Contradiction) is" # see Kojima et al 2022 A.5
    second_response = utils.call_gpt_withlogging(second_prompt,
                                                  args.model,
                                                  max_tokens=(max_tokens-len(first_response.split()))) # approximate

    if is_entail(json_item["answer"]):
        groundtruth = ENTAILMENT
    else:
        groundtruth = CONTRADICTION

    entail = "entail" in second_response.lower()
    contradict = "contradict" in second_response.lower()
    if entail and contradict:
        print("Got BOTH entail and contradict!")
        response = "unclear"
    elif entail:
        response = ENTAILMENT
    elif contradict:
        response = CONTRADICTION
    else:
        response = "unclear"

    with open(suggested_filename, "a") as f:
        formatted_output = ("{:15s}".format(json_item["case id"]) +
                "GPT Response: {:20s}".format(second_response) +
                "Interpreted as: {:15s}".format(response) +
                "Groundtruth: " + json_item["answer"])
        log_to_file_and_print(f, formatted_output)

        if has_dollar:
            dollar_groundtruth_vs_response[groundtruth][response] += 1
            log_to_file_and_print(f,"dollar_groundtruth_vs_response" + str(dollar_groundtruth_vs_response))
        else:
            nodollar_groundtruth_vs_response[groundtruth][response] += 1
            log_to_file_and_print(f,"nodollar_groundtruth_vs_response" + str(nodollar_groundtruth_vs_response))

print("FINAL dollar_groundtruth_vs_response:")
print_confusion_matrix(dollar_groundtruth_vs_response)
print("FINAL nodollar_groundtruth_vs_response:")
print_confusion_matrix(nodollar_groundtruth_vs_response)
