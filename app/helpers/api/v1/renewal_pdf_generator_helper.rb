module Api::V1::RenewalPdfGeneratorHelper
  def generate_renewal_pdf
    pdf = Prawn::Document.new

    # Add logo (Assuming you have the logo saved in app/assets/images/)
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
    pdf.text "Amount: ₦#{'%.2f' % amount}", size: 12
    pdf.text "Due Date: #{deadline.strftime('%B %d, %Y')}", size: 12
    pdf.text "Month: #{Date::MONTHNAMES[month]}", size: 12
    pdf.text "Year: #{year}", size: 12

    if status == "receipt"
      pdf.text "Date of Renewal: #{date_of_renewal.strftime('%B %d, %Y') if date_of_renewal}", size: 12
    end

    # Footer
    pdf.move_down 30
    pdf.text "Thank you for choosing Starlink Solutions.", align: :center

    pdf.render
  end
end