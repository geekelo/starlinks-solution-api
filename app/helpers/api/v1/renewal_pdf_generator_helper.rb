require 'prawn'

module Api::V1::RenewalPdfGeneratorHelper
  def self.generate_renewal_pdf
    pdf = Prawn::Document.new

    # Load UTF-8 compatible font
    font_path = Rails.root.join("app/assets/fonts/DejaVuSans.ttf")
    pdf.font font_path

    # Add logo (if exists)
    logo_path = Rails.root.join("app/assets/images/starlink_logo.png")
    pdf.image logo_path, width: 100, height: 100 if File.exist?(logo_path)

    # Header
    document_title = status == "invoice" ? "Renewal Invoice" : "Renewal Receipt"
    pdf.move_down 20
    pdf.text "#{document_title} for Kit Number #{starlink_kit_id}", size: 18, style: :bold

    # Business Address
    pdf.move_down 10
    pdf.text "Starlink Solutions", size: 14, style: :bold
    pdf.text "28, Kodesho Street, Beside Ikeja Plaza, Ikeja, Lagos State", size: 12

    # Renewal Details
    pdf.move_down 20
    pdf.text "Amount: ₦#{'%.2f' % (amount || 0).to_f}", size: 12  # ✅ FIXED
    pdf.text "Due Date: #{deadline&.strftime('%B %d, %Y') || 'N/A'}", size: 12
    pdf.text "Month: #{Date::MONTHNAMES[month] || 'N/A'}", size: 12
    pdf.text "Year: #{year || 'N/A'}", size: 12

    if status == "receipt"
      pdf.text "Date of Renewal: #{date_of_renewal&.strftime('%B %d, %Y') || 'N/A'}", size: 12
    end

    # Footer
    pdf.move_down 30
    pdf.text "Thank you for choosing Starlink Solutions.", align: :center

    pdf.render
  end
end
