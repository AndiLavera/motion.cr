export default interface ITarget {
  formData: {} | null;
  tagName: string;
  value: string;
  attributes: {
    class: string;
    'data-motion': string;
  };
}
