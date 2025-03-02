require 'prawn'

module Api::V1::RenewalPdfGeneratorHelper
  def self.generate_renewal_pdf(renewal)
    Prawn::Document.new do |pdf|
      # Add Starlink logo and company details
      add_company_info_to_pdf(pdf)

      pdf.move_down 30
      document_title = renewal.status == "invoice" ? "Renewal Invoice" : "Renewal Receipt"
      pdf.text "#{document_title} - Kit ##{renewal.starlink_kit_id}", size: 20, style: :bold, align: :center
      pdf.move_down 10
      pdf.stroke_horizontal_rule
      pdf.move_down 10
      pdf.text "Invoice Date: #{renewal.created_at.strftime('%B %d, %Y')}", size: 12
      pdf.move_down 20

      # Renewal Details Table
      pdf.text "Renewal Details", size: 18, style: :bold
      pdf.move_down 10
      table_data = [
        ["Item Description", "Amount"],
        ["Starlink Kit Renewal", "₦#{renewal.amount || 'N/A'}"]
      ]
      pdf.table(table_data, width: pdf.bounds.width) do |table|
        table.header = true
        table.row_colors = %w[f0f0f0 ffffff]
        table.cell_style = { borders: [:top, :bottom], border_width: 1, padding: [5, 10] }
      end

      # Additional Details
      pdf.move_down 20
      pdf.text "Due Date: #{renewal.deadline&.strftime('%B %d, %Y') || 'N/A'}", size: 12
      pdf.text "Month: #{Date::MONTHNAMES[renewal.month.to_i] || 'N/A'}", size: 12
      pdf.text "Year: #{renewal.year || 'N/A'}", size: 12

      if renewal.status == "receipt"
        pdf.text "Date of Renewal: #{renewal.date_of_renewal&.strftime('%B %d, %Y') || 'N/A'}", size: 12
      end

      # Footer
      add_footer_to_pdf(pdf)
    end.render
  end

  private

  def self.add_company_info_to_pdf(pdf)
    logo_path = Rails.root.join("app/assets/images/starlink_logo.png")
    if File.exist?(logo_path)
      pdf.image logo_path, width: 100, height: 100, at: [0, pdf.cursor]
    end

    pdf.bounding_box([120, pdf.cursor], width: pdf.bounds.width - 120) do
      pdf.text "Starlink Solutions", size: 24, style: :bold
      pdf.text "28, Kodesho Street, Beside Ikeja Plaza, Ikeja, Lagos State", size: 12, style: :italic
      pdf.move_down 20
    end
  end

  def self.add_footer_to_pdf(pdf)
    pdf.move_down 40
    pdf.stroke_horizontal_rule
    pdf.move_down 10
    pdf.text "Thank you for choosing Starlink Solutions!", align: :center, size: 12, style: :italic
  end
end
