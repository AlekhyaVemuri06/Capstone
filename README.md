# 🧬 Sequential Sentence Classification — PubMed 20k RCT
## AI Engineer Capstone Project · Intel Arc XPU Edition

---

## 📁 Project Structure

```
capstone_project/
├── Sequential_Sentence_Classification_XPU.ipynb   ← Main notebook (PyTorch / Intel Arc XPU)
├── setup_venv.bat                                 ← Windows setup — Command Prompt
├── setup_venv.ps1                                 ← Windows setup — PowerShell
├── README.md
├── Sequential_Sentence_Classification_v3.pptx     ← Business presentation deck
└── pubmed_data/
    └── PubMed_20k_RCT/
        ├── train.txt   (~180k sentences, ~15k abstracts)
        ├── dev.txt     (~30k sentences)
        └── test.txt    (~30k sentences)
```

---

## ⚙️ Environment Setup — Windows (Python venv)

> **TensorFlow is not used in this project.** All deep learning runs on native
> PyTorch with Intel Arc XPU support. Do not install `tensorflow` or `tf-keras`.

### Option A: Command Prompt / Double-click
```bat
setup_venv.bat
```

### Option B: PowerShell
```powershell
powershell -ExecutionPolicy Bypass -File setup_venv.ps1
```

### Option C: Manual steps
```bat
:: 1. Initialise Intel oneAPI environment (required before installing PyTorch XPU)
"C:\Program Files (x86)\Intel\oneAPI\setvars.bat"

:: 2. Create and activate venv
python -m venv venv
venv\Scripts\activate.bat

:: 3. PyTorch nightly with native Intel Arc XPU support
pip install --pre torch torchvision torchaudio ^
    --index-url https://download.pytorch.org/whl/nightly/xpu

:: 4. HuggingFace — PyTorch-native only, no TF extras
pip install transformers==4.47.0 accelerate

:: 5. Sentence Transformers for Model 2 (already PyTorch, no changes needed)
pip install sentence-transformers

:: 6. ML utilities
pip install scikit-learn pandas numpy matplotlib seaborn

:: 7. Register Jupyter kernel and launch
pip install jupyter ipykernel
python -m ipykernel install --user --name=capstone_venv ^
    --display-name "Python (capstone_venv — XPU)"
jupyter notebook Sequential_Sentence_Classification_XPU.ipynb
```

### Verify XPU is working before running the notebook
```python
import torch
print(torch.xpu.is_available())        # must be True
print(torch.xpu.get_device_name(0))    # e.g. "Intel(R) Arc(TM) A770 Graphics"
```

---

## ⚠️ Pre-requisites for Intel Arc XPU

Three steps are required before the notebook will use the GPU. Skip any of
these and the notebook will fall back to CPU automatically, but training
will be 5–8× slower.

**1. Enable Resizable BAR in BIOS**
- Reboot → BIOS/UEFI → Advanced → PCI Configuration
- Enable *Above 4G Decoding* and *Re-Size BAR Support*
- Save and reboot

**2. Install Intel Arc GPU Driver**
- Minimum version: 31.0.101.5522
- Download from: https://www.intel.com/content/www/us/en/download/785597

**3. Install Intel oneAPI Base Toolkit**
- Required for the GPU runtime (Level Zero / SYCL)
- Download from: https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html
- Run `setvars.bat` in every new terminal session before launching Jupyter

---

## ⚠️ PowerShell Execution Policy

If PowerShell blocks the setup script, run this once as Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```
Or pass the bypass flag per-run:
```powershell
powershell -ExecutionPolicy Bypass -File setup_venv.ps1
```

---

## 🤖 Models

| # | Model | Architecture | Framework | Expected Accuracy |
|---|---|---|---|---|
| 0 | Naïve Bayes + TF-IDF | TF-IDF (50k bigrams) → MultinomialNB | scikit-learn | ~73% |
| 1 | Conv1D Token Embedding | Token embed (128d) → 3×Conv1D → Dense | PyTorch / XPU | ~81% |
| 2 | MiniLM Feature Extractor | all-MiniLM-L6-v2 (384d, frozen) → Dense head | PyTorch / XPU | ~85% |
| 3 | Conv1D Char Embedding | Char embed (64d) → 5×Conv1D → Dense | PyTorch / XPU | ~79% |
| 4 | BERT Fine-tuning | bert-base-uncased → [CLS] (768d) → Linear | PyTorch / XPU | ~90% |

> **Model 2 note:** The original notebook used Universal Sentence Encoder (USE) via
> `tensorflow-hub`, which is broken on Python 3.12 Windows due to a `pkg_resources`
> conflict. This has been replaced with `all-MiniLM-L6-v2` from `sentence-transformers` —
> same concept (pretrained sentence embeddings + trainable dense head), better quality,
> no dependency issues.

---

## ⚡ XPU Performance vs CPU

| Model | CPU (original TF) | Arc A380 6GB | Arc A770 16GB |
|---|---|---|---|
| M0 Naïve Bayes | ~1 min | ~1 min | ~1 min |
| M1 Conv1D Token | ~3 hrs | ~35 min | ~20 min |
| M2 MiniLM | ~4 hrs | ~60 min | ~35 min |
| M3 Conv1D Char | ~3 hrs | ~35 min | ~20 min |
| M4 BERT | ~8 hrs | ~90 min | ~45 min |
| **Total** | **~18 hrs** | **~3.7 hrs** | **~2 hrs** |

---

## 📦 Package Versions (February 2026)

| Package | Version | Purpose |
|---|---|---|
| Python | 3.12.10 | |
| torch | nightly/xpu | All deep learning (Models 1–4) |
| transformers | 4.47.0 | BERT tokeniser and model (Model 4) |
| accelerate | latest | HuggingFace training utilities |
| sentence-transformers | latest | MiniLM encoder (Model 2) |
| scikit-learn | 1.8.0 | TF-IDF + Naïve Bayes (Model 0), metrics |
| numpy | ≥1.26 | |
| pandas | latest | |
| matplotlib / seaborn | latest | Plots |
| tensorflow | ❌ not installed | No Intel Arc XPU support |
| tf-keras | ❌ not installed | |
| tensorflow-hub | ❌ not installed | Broken on Python 3.12 Windows |

---

## 📊 Labels

| Label | Role |
|---|---|
| `BACKGROUND` | Context and prior work |
| `OBJECTIVE` | Study aim or hypothesis |
| `METHODS` | How the study was conducted |
| `RESULTS` | Key findings |
| `CONCLUSIONS` | Interpretation and implications |

---

## 💾 Saved Model Artefacts

After running CELL 22, the following are written to `./models/`:

```
models/
├── model0_nb.pkl               ← sklearn Pipeline (TF-IDF + Naïve Bayes)
├── model1_conv1d_token.pt      ← Conv1DTokenModel weights (state_dict)
├── model2_minilm_head.pt       ← SBertHead weights (state_dict)
├── model3_conv1d_char.pt       ← Conv1DCharModel weights (state_dict)
├── model4_bert/
│   ├── config.json
│   ├── pytorch_model.bin       ← BertForSequenceClassification weights
│   ├── tokenizer_config.json
│   └── vocab.txt
├── word2idx.pkl                ← Token vocabulary (Model 1)
├── char2idx.pkl                ← Character vocabulary (Model 3)
└── label_encoder.pkl           ← LabelEncoder (5 classes)
```

---

*Capstone Project | AI Engineer Program | PubMed 20k RCT | February 2026*
