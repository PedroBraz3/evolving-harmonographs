from flask import Flask, request, jsonify
import numpy as np
from PIL import Image
import io
import base64
from tensorflow.keras.applications import VGG16
from tensorflow.keras.applications.vgg16 import preprocess_input
import tensorflow as tf
from sklearn.metrics.pairwise import cosine_similarity

app = Flask(__name__)

# Carrega a rede pré-treinada VGG16 (sem a parte de classificação)
model = VGG16(weights='imagenet', include_top=False, pooling='avg')

# Carrega imagem alvo e redimensiona para 256x256
target_pil = Image.open("objetivo/2025-09-28-18-26-08.png").convert("RGB").resize((256,256))

def get_features(img_pil):
    """Extrai features da imagem usando VGG16"""
    x = np.expand_dims(np.array(img_pil), axis=0)
    x = preprocess_input(x)
    features = model.predict(x, verbose=0)
    return features

# Extrai features do alvo
feat_target = get_features(target_pil)

@app.route("/evaluate", methods=["POST"])
def evaluate():
    data = request.json
    img_bytes_list = data["image_bytes"]
    img_bytes = bytes(img_bytes_list)
    
    # Reconstrói imagem enviada pelo indivíduo
    indiv_pil = Image.frombytes("RGB", (256, 256), img_bytes).convert("RGB").resize((256,256))
    
    # Extrai features do indivíduo
    feat_indiv = get_features(indiv_pil)
    
    # Similaridade perceptual (cosine similarity entre vetores de features)
    fitness = float(cosine_similarity(feat_target, feat_indiv)[0,0])
    fitness = np.clip(fitness, 0.0, 1.0)  # garante que fique entre 0 e 1
    
    return jsonify({"fitness": fitness})

if __name__ == "__main__":
    # Evita o TensorFlow poluir o console
    tf.get_logger().setLevel('ERROR')
    app.run(port=5000)
