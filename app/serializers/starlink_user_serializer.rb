class StarlinkUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :password, :phone_number, :name, :whatsapp_number
end
