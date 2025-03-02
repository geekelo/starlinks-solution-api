require 'prawn'

module Api::V1::RenewalPdfGeneratorHelper
  def self.generate_renewal_pdf(renewal)
    pdf = Prawn::Document.new

    # Load UTF-8 compatible font
    font_path = Rails.root.join("app/assets/fonts/DejaVuSans.ttf")
    pdf.font font_path if File.exist?(font_path)

    # Add logo (if exists)
    logo_path = Rails.root.join("app/assets/images/starlink_logo.png")
    pdf.image logo_path, width: 100, height: 100 if File.exist?(logo_path)

    # Header
    document_title = renewal.status == "invoice" ? "Renewal Invoice" : "Renewal Receipt"
    pdf.move_down 20
    pdf.text "#{document_title} for Kit Number #{renewal.starlink_kit_id}", size: 18, style: :bold

    # Business Address
    pdf.move_down 10
    pdf.text "Starlink Solutions", size: 14, style: :bold
    pdf.text "28, Kodesho Street, Beside Ikeja Plaza, Ikeja, Lagos State", size: 12



    # Footer
    pdf.move_down 30
    pdf.text "Thank you for choosing Starlink Solutions.", align: :center

    pdf.render
  end
end
