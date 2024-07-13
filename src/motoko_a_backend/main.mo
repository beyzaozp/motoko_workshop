import Hash "mo:base/Hash";
import Map "mo:base/HashMap";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";

actor SocialMedia {
  type Post = {
    author : Principal;
    content : Text;
    timestamp : Time.Time;
    likes : Nat;
  };

  func natHash(n : Nat) : Hash.Hash {
    Text.hash(Nat.toText(n));
  };

  var posts = Map.HashMap<Nat, Post>(0, Nat.equal, natHash); //Hönderilen IDleri ile eşleştirildiği HashMap
  var nextId : Nat = 0; //Bir sonraki gönderi Idsini tutan değer

  // Tüm gönderileri getirme işlemi
  public query func getPosts() : async [(Nat, Post)] {
    // Tüm gönderileri döndüren query fonksiyonu
    Iter.toArray(posts.entries()); // HashMap içindeki tüm gönderileri diziye dönüştürüyor
  };

  // Yeni gönderi ekleme işlemi
  public shared (msg) func addPost(content : Text) : async Text {
    // Yeni gönderi ekleyen fonksiyon
    let id = nextId; // Yeni gönderi ID'si oluşturuluyor
    posts.put(id, { author = msg.caller; content = content; timestamp = Time.now(); likes = 0 }); // Gönderi HashMap'e ekleniyor
    nextId += 1; // Bir sonraki gönderi ID'si artırılıyor
    "Gönderi başarıyla eklendi. Gönderi ID'si: " # Nat.toText(id); // Sonuç metni döndürülüyor
  };

  // Belirli bir gönderiyi görüntüleme işlemi
  public query func viewPost(id : Nat) : async ?Post {
    // Belirli bir gönderiyi döndüren query fonksiyonu
    posts.get(id); // Gönderiyi ID'si ile getiriyor
  };
  // Tüm gönderileri temizleme işlemi
  public func clearPosts() : async () {
    // Tüm gönderileri temizleyen fonksiyon
    for (key : Nat in posts.keys()) {
      // HashMap içindeki tüm anahtarları alıyor
      ignore posts.remove(key); // Gönderileri temizliyor
    };
  };

  // Gönderi beğenme işlemi
  public func likePost(id : Nat) : async Text {
    switch (posts.get(id)) {
      case (?post) {
        let updatedPost = { post with likes = post.likes + 1 };
        posts.put(id, updatedPost);
        "Gönderi başarıyla beğenildi. Gönderi ID'si: " # Nat.toText(id);
      };
      case null "Gönderi bulunamadı. Gönderi ID'si: " # Nat.toText(id);
    };
  };

  // Toplam gönderi sayısını alma işlemi
  public query func getPostCount() : async Nat {
    posts.size();
  };
  
};
