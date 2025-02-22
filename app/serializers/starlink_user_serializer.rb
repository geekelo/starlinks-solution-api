class StarlinkUserSerializer < ActiveModel::Serializer
  attributes :id, :email, :password, :phone_number, :name, :whatsapp_number,
             :email_confirmed, :whatsapp_number_confirmed, :created_at, :updated_at
end
