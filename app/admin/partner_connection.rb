ActiveAdmin.register PartnerConnection do
  belongs_to :partner

  permit_params :imap_provider_id,
                *Plain::PartnerConnection.connection_fields,
                *Oauth1::PartnerConnection.connection_fields,
                *Oauth2::PartnerConnection.connection_fields

  controller do
    def create
      imap_provider = ImapProvider.find(params[:partner_connection][:imap_provider_id])
      new_type = imap_provider.type.gsub("::ImapProvider", "::PartnerConnection")
      params[:partner_connection].merge!(:type => new_type)
      super
    end
  end

  breadcrumb do
    partner = Partner.find(params[:partner_id])
    [
      link_to("Partners", admin_partners_path),
      link_to(partner.name, admin_partner_path(partner)),
      link_to("Connections", admin_partner_partner_connections_path(partner))
    ]
  end

  config.filters = false

  index do
    column "Auth Mechanism" do |obj|
      link_to obj.imap_provider_code, admin_partner_partner_connection_path(obj.partner, obj)
    end

    column "Links" do |obj|
      raw [
        link_to("Connection Type",
                admin_imap_provider_path(obj)),
        link_to("Users (#{obj.users_count})",
                admin_partner_connection_users_path(obj))
      ].join(", ")
    end
    actions
  end

  show do |obj|
    panel "Details" do
      attributes_table_for obj do
        row :imap_provider_code
      end
    end
    panel "Connection Settings" do
      attributes_table_for obj do
        obj.connection_fields.map do |field|
          row field
        end
      end
    end if obj.connection_fields.present?
  end

  form do |f|
    f.inputs "Details" do
      f.input :imap_provider, :label => "Auth Mechanism"
    end if f.object.new_record?

    if !f.object.new_record? && f.object.connection_fields.present?
      f.inputs "Connection Settings", *f.object.connection_fields
    end

    f.actions
  end
end
