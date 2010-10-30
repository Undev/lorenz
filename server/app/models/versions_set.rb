class NestedHash < Hash
  
  def NestedHash.from_hash(hash)
    new_hash = new
    hash.each do |k, v|
      new_hash[k] = v.is_a?(Hash) ? from_hash(v) : v
    end
    new_hash
  end
  def initialize
    blk = lambda {|h,k| h[k] = NestedHash.new(&blk)}
    super(&blk)
  end
end

class Hash
   def Hash.new_nested_hash
     Hash.new{|h,k| h[k]=Hash.new(&h.default_proc) }
   end
end

class VersionsSet
  
  SETUP = { 'packages' => {}, 'hosts' => {}, 'variants' => {}}
  
  include Ripple::Document
  property :name, String
  property :data, Hash, :default => {}
  key_on :name
  
  class << self
    def default
      @@default ||= begin
        set = self.find('default') || self.create(:name => 'default')
        set.set_lorenz
        set
      end
    end
    
  end
  
  def nested_data
    @nested_data ||= NestedHash.from_hash(data)
  end
  
  # FIXME: написать это по-человечески
  
  # Почему то если возвращать например variants[params[:variant]] ||= {}, то возвращается не ссылка на хэш внутри data, а _какой-то другой_ хеш
  def collection_by(params = {}, &blk)
    if params[:host_name].present? && params[:variant].present?      
      nested_data['hosts'][params[:host_name]]['variants'][params[:variant]]
    elsif params[:host_name].present?
      nested_data['hosts'][params[:host_name]]['packages']
    elsif params[:variant].present?
      nested_data['variants'][params[:variant]]
    else
      nested_data['packages']
    end
  end
  
  def cleanup
    nested_data['hosts'].each do |host_k, host_v|
      if host_v['variants'].blank? && host_v['packages'].blank?
        nested_data['hosts'].delete(host_k)
      end
      nested_data['variants'].delete_if { |variant_k, variant_v| variant_v.blank? }
    end
    nested_data['variants'].delete_if { |k, v| v.blank? }
  end
  
  def add(params = {})
    collection_by(params)["#{params[:package_type]}-#{params[:package_name]}"] = params[:version]
    set_lorenz
    self.data = nested_data
    save
  end
  
  def remove(params = {})
    collection_by(params).delete(params[:package])
    cleanup
    set_lorenz
    self.data = nested_data
    save
  end
  
  def to_data
    res = {}
    nested_data['packages'].each do |k, v|
      res[k] = v
    end

    nested_data['variants'].each do |variant_k, variant_v|
      variant_v.each do |k, v|
        res["variant-#{variant_k}-#{k}"] = v
      end
    end
    
    nested_data['hosts'].each do |host_k, host_v|
      host_v['packages'].each do |k, v|
        res["#{host_k}-#{k}"] = v
      end
      nested_data['variants'].each do |variant_k, variant_v|
        variant_v.each do |k, v|
          res["#{host_k}-#{variant_k}-#{k}"] = v
        end
      end
    end
    res
  end
  
  def set_lorenz
    Lorenz.versions.data = to_data
  end
  
  def to_json
    to_data.to_json
  end
end