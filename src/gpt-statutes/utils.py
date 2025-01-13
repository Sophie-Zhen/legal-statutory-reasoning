# updated 13 Jan 2025
# Provides helper functions for doing SARA tests against gpt-4o-2024-08-06

# import libraries
import os
import time
from datetime import datetime
from openai import OpenAI
from openai import OpenAIError, RateLimitError, APIError
from tenacity import retry, stop_after_attempt, wait_exponential
import logging


# Initialize the client
client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
GPT_LOGFILE = "gpt_log.txt"

logging.basicConfig(filename=GPT_LOGFILE, level=logging.INFO, format='%(asctime)s - %(message)s')
@retry(stop=stop_after_attempt(5), wait=wait_exponential(multiplier=1, min=4, max=10))

def call_api(client, engine, prompt, **kwargs):
    # if engine in ["o1-preview-2024-09-12", "gpt-4o-2024-08-06"]:
    return client.chat.completions.create(model=engine, messages=[{"role": "user", "content": prompt}], **kwargs)
    # else:
    #     return client.completions.create(model=engine, prompt=prompt, **kwargs)

def add_comment(comment: str):
    with open(GPT_LOGFILE, "a") as f:
        f.write(datetime.now().strftime("%A %d-%B-%Y %H:%M:%S") + "  COMMENT:" + comment + "\n")
        f.flush()
        f.close()


def call_gpt_withlogging(prompt: str,
                         engine: str,
                         temperature: float = 0.0,
                         max_tokens: int = 256,
                         top_p: float = 1.0,
                         frequency_penalty: float = 0.0,
                         presence_penalty: float = 0.0) -> str:
    
    logging.info(f"API Call - Engine: {engine}, Temp: {temperature:.2f}, Max Tokens: {max_tokens}, "
                 f"Top P: {top_p:.2f}, Freq Penalty: {frequency_penalty:.2f}, Pres Penalty: {presence_penalty:.2f}")
    logging.info(f"Prompt: {prompt}")

    try:
        if engine.startswith("o1-"):
            response = call_api(client, engine, prompt, temperature=1, max_completion_tokens=max_tokens,
                            top_p=top_p, frequency_penalty=frequency_penalty, presence_penalty=presence_penalty)
        else:
            response = call_api(client, engine, prompt, temperature=temperature, max_tokens=max_tokens,
                            top_p=top_p, frequency_penalty=frequency_penalty, presence_penalty=presence_penalty)
        # if engine in ["o1-2024-12-17", "gpt-4o-2024-08-06"]:
        response_text = response.choices[0].message.content
        # else:
        #     response_text = response.choices[0].text
        
        logging.info(f"Response: {response_text}")
        return response_text
    
    except RateLimitError as e:
        logging.error(f"Rate limit exceeded: {e}")
        raise
    except APIError as e:
        if e.status_code == 503:
            logging.error(f"Service unavailable: {e}")
        else:
            logging.error(f"API error occurred: {e}")
        raise
    except OpenAIError as e:
        logging.error(f"OpenAI error occurred: {e}")
        raise



# This calls GPT directly, without the wrapper, called in call_gpt_with_sara_numerical
def call_gpt_api(client, engine, messages, **kwargs):
    return client.chat.completions.create(model=engine, messages=messages, **kwargs)

def call_gpt_raw(messages: list,
                 engine: str,
                 temperature: float = 0.0,
                 max_tokens: int = 1000,
                 top_p: float = 1.0,
                 frequency_penalty: float = 0.0,
                 presence_penalty: float = 0.0) -> str:
    """
    Calls OpenAI GPT model with logging and retries.

    Parameters:
        messages (list): List of message dictionaries for the chat API.
        engine (str): The GPT model to use (e.g., 'gpt-4', 'gpt-4-turbo').
        temperature (float): Sampling temperature.
        max_tokens (int): Maximum number of tokens in the response.
        top_p (float): Top-p sampling for diversity.
        frequency_penalty (float): Penalize repeated tokens.
        presence_penalty (float): Penalize based on token presence.

    Returns:
        str: Model response content.
    """
    logging.info(f"API Call - Engine: {engine}, Temp: {temperature:.2f}, Max Tokens: {max_tokens}, "
                 f"Top P: {top_p:.2f}, Freq Penalty: {frequency_penalty:.2f}, Pres Penalty: {presence_penalty:.2f}")
    logging.info(f"Messages: {messages}")

    try:
        if engine.startswith("o1-"):
            response = call_gpt_api(
                client,
                engine,
                messages,
                temperature=1,
                max_completion_tokens=max_tokens,
                top_p=top_p,
                frequency_penalty=frequency_penalty,
                presence_penalty=presence_penalty
            )
        else:
            response = call_gpt_api(
                client,
                engine,
                messages,
                temperature=temperature,
                max_tokens=max_tokens,
                top_p=top_p,
                frequency_penalty=frequency_penalty,
                presence_penalty=presence_penalty
            )
        response_text = response.choices[0].message.content
        logging.info(f"Response: {response_text}")
        return response_text

    except RateLimitError as e:
        logging.error(f"Rate limit exceeded: {str(e)}")
        raise
    except APIError as e:
        if e.status_code == 400:
            print("Invalid request error -- trying fewer tokens")
            max_tokens -= 50
            if max_tokens <= 0:
                raise ValueError("Fewer tokens did not solve the problem")
            # Retry the API call with reduced max_tokens
            # Insert retry logic here
        else:
            print(f"API error occurred: {e}")
            logging.error(f"API error occurred: {str(e)}")
            raise
    except Exception as e:
        logging.error(f"Unexpected error occurred: {str(e)}")
        raise



def get_cases(test_or_train:str, exclude_dollars=False, only_tax_cases=False) -> list:
    rv = []
    f = open("./sara_v2/splits/" + test_or_train, "r")
    for l in f.readlines():
        if only_tax_cases and not l.startswith("tax_case"):
            continue

        f_casefile = open("./sara_v2/cases/" + l.strip() + ".pl", "r")

        text = ""
        line = f_casefile.readline()
        assert line.strip() == "% Text"
        line = f_casefile.readline()
        while line.startswith("% "):
            text += line[len("% "):]
            line = f_casefile.readline()

        question = ""
        line = f_casefile.readline()
        assert line.strip() == "% Question"
        line = f_casefile.readline()
        while line.startswith("% "):
            question += line[len("% "):]
            line = f_casefile.readline()

        remaining_text = ""
        for line in f_casefile.readlines():
            remaining_text += line

        if not exclude_dollars or not ("$" in text or "$" in question):
            rv.append((l.strip(), text.strip(), question.strip(), remaining_text.strip()))

    return rv

def print_case_breakdown():
    for split in ["train", "test"]:
        print("SARA", split, ":")
        total = get_cases(split)
        nodollar = get_cases(split, exclude_dollars=True)
        tax_only = get_cases(split, exclude_dollars=False, only_tax_cases=True)
        print("     nodollar =", len(nodollar))
        print("dollar entail =", len(total) - len(nodollar) - len(tax_only))
        print("      taxonly =", len(tax_only))
        print("        TOTAL =", len(total))

def is_entail(text) -> bool:
    return text.lower().replace(".", "").strip() == "entailment"

def is_contra(text) -> bool:
    return text.lower().replace(".", "").strip() == "contradiction"

def is_entail_or_contra(text) -> bool:
    return is_contra(text) or is_entail(text)

# Even when given the second prompt "Therefore, the answer (Yes or No) is", GPT3 sometimes
# gives answers with lots of random punctuation other than just "Yes" or "No".
# Annoyingly this sometimes includes a whole long sentence after the "Yes" or "No"
def is_match(response:str, query:str) -> bool:
    clean = response.replace(".","").replace(":","").replace("-","").replace(":","").strip()
    return clean.lower().startswith(query)
def is_yes(response:str) -> bool:
    return is_match(response, "yes")
def is_no(response:str) -> bool:
    return is_match(response, "no")

AMBIGUOUS_WORDS = ["depend", "depends", "dependent", "may", "maybe", "if", "but"] # a suggestion of problem words
def warning_if_problem_words(list_problem_words, target:str, context:str) -> str:
    rv = ""
    for problem_word in list_problem_words:
        if problem_word.lower() in target.lower().split():
            rv += "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
            rv += "!WARNING: found problem word " + problem_word + " in: " + target + "\n"
            rv += "!Context: " + context + "\n"
            rv += "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
    return rv

def reformat_case(text, first, second, third, skip_third=False, add_cite_before_section=False) -> str:
    if add_cite_before_section: # used for testing without the statutes in the prompt
        text = text.replace("section", "I.R.C. section")
        text = text.replace("Section", "I.R.C. section")

    assert len(text.split("\n")) == 2
    first_part = text.split("\n")[0]
    if not skip_third:
        last = text.split("\n")[1].split()[-1]
        assert is_entail_or_contra(last)
    else:
        last = ""
    second_part = text.split("\n")[1]
    second_part = second_part[0:len(second_part) - len(last)].strip() # off with "Entailment" etc

    return first + first_part + "\n" + \
            second + second_part + "\n" + \
            third + last


def print_confusion_matrix(entail_cor, contra_cor, entail_answercontra, contra_answerentail):
    print("                ", "      Predicted         ")
    print("                ", "  entail      contrad.  ")
    print("Actual  entail  ", "  {:6d} ".format(entail_cor), "   {:6d} ".format(entail_answercontra))
    print("        contrad.", "  {:6d} ".format(contra_answerentail), "   {:6d} ".format(contra_cor))
    total = entail_cor+ contra_cor+ entail_answercontra+ contra_answerentail
    corr = entail_cor+ contra_cor
    if total > 0:
        print("Accuracy:", corr, "/", total, "=", corr/float(total))
    else:
        assert corr == 0
        print("Accuracy:", 0, "/", 0, "=", 0)


def remove_statute_whitespace(orig_text) -> str:
    rv = orig_text.replace("\n\n", "\n")
    return rv

# if __name__ == "__main__":
#     print("TEST")
#     tests = get_cases("test", True)
#     for t in tests:
#         print(t)
#         assert t[2].endswith("Contradiction") or t[2].endswith("Entailment")
#     print("TRAIN")
#     train = get_cases("train", True)
#     for t in train:
#         print(t)
#         assert t[2].endswith("Contradiction") or t[2].endswith("Entailment")

#     print_case_breakdown()